extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var States = {"LOCKED":0, "DEFAULT":1, "CLICKED": 2, "PLACED":3, "SELECTED":4}

var state = States.PLACED
var coords
var side = "PLAYER"
var cursor_area
var name = ""
var cooldown = 0
var ultimate_flag = false

const SHOVE_SPEED = 4

signal invalid_move
signal description_data(unit_name, description)
signal hide_description
signal animation_done
signal shake

signal pre_attack(attack_coords)

signal stepped_move_completed

signal targeted

var mid_animation = false #to handle the bug of the clickarea not moving until everything's done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	set_process_input(true)
	set_process(true)
	
func set_cooldown(cooldown):
	self.cooldown = cooldown + 1 #offset for the first countdown tick

	
func is_placed():
	return self.state == States.PLACED

func delete_self():
	get_parent().remove_piece(self.coords)
	remove_from_group("player_pieces")
	self.queue_free()

func initialize(cursor_area):
	self.cursor_area = cursor_area
	set_z(-1)
	add_to_group("player_pieces")
	
func turn_update():
	if self.cooldown > 0:
		pass
	else:
		self.state = States.DEFAULT
		get_node("Cooldown").hide()
		get_node("AnimatedSprite").play("default")
		if(get_node("ClickArea").overlaps_area(self.cursor_area)):
			self.hovered()

func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords

#ANIMATION FUNCTIONS
func animate_summon():
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
func animate_move_to_pos(position, speed, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	self.mid_animation = true
	var distance = get_pos().distance_to(position)
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, trans_type, ease_type)
	get_node("Tween").start()

func animate_move(new_coords, speed=250, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed, trans_type, ease_type)

#move from tile to tile
func animate_stepped_move(new_coords, pathed_range, speed=250, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var path = []
	var current_pathed_coords = pathed_range[new_coords]
	while(current_pathed_coords.coords != self.coords):
		path.push_front(current_pathed_coords.coords)
		current_pathed_coords = current_pathed_coords.previous
		
	for coords in path:
		animate_move(coords, speed, trans_type, ease_type)
		yield(get_node("Tween"), "tween_complete")
		
	emit_signal("stepped_move_completed")
	
func attack_highlight():
	pass
	
func assist_highlight():
	get_node("AnimatedSprite").play("assist")
	
func assist_hover_highlight():
	get_node("AnimatedSprite").play("assist_light")

#called when the whole board's highlighting is reset
func reset_highlight():
	if(self.state != States.PLACED):
		get_node("AnimatedSprite").play("default")
		get_node("LightenLayer").hide()
	else:
		get_node("AnimatedSprite").play("cooldown")

func reset_prediction_highlight():
	pass
	#get_node("Physicals/AnimatedSprite").show()
	#get_node("Physicals/PredictionLayer").hide()
	

#called on mouse entering the ClickArea
func hover_highlight():
	if(self.state != States.PLACED):
		get_node("LightenLayer").show()


#called on mouse exiting the ClickArea
func unhovered():
	emit_signal("hide_description")
	get_node("LightenLayer").hide()
	if get_parent().selected == null:
		get_parent().reset_highlighting()
#		
#	elif get_parent().selected == self:
#		reset_highlight()
		

#called when hovered over during player turn		
func hovered():
	get_node("Timer").set_wait_time(0.05)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	if !self.mid_animation:
		hover_highlight()
	emit_signal("description_data", self.UNIT_TYPE, self.DESCRIPTION)
	if get_parent().selected == null and self.state != States.PLACED:
		display_action_range()
#	elif get_parent().selected == self:
#		if self.mid_animation == false: #to handle the bug of the clickarea not moving until everything's done
#			hover_highlight()
#		else:
#			print("caught the click area bug")



#called when an event happens inside the click area hitput
func input_event(viewport, event, shape_idx):
	if event.is_action("select") and event.is_pressed():
		if get_parent().selected == null and self.state != States.PLACED:
			get_parent().selected = self
			self.state = States.CLICKED
			get_node("BlueGlow").show()
			hovered()
		else: #if not selected, then some piece is trying to act on this one
			get_parent().set_target(self)


func deselect():
	self.state = States.DEFAULT
	get_node("BlueGlow").hide()

func select_action_target(target):
	print("calling select_action_target")
	if target.coords == self.coords:
		print("calling cast ultimate from select_action_target")
		cast_ultimate()
	else:
		get_parent().reset_highlighting()
		get_node("BlueGlow").hide()
		act(target.coords)

#helper function for act
func invalid_move():
	emit_signal("invalid_move")
	self.state = States.DEFAULT
	get_parent().selected = null

#helper function for act
func placed():
	if(self.cooldown > 0):
		self.cooldown -= 1
		get_node("Cooldown").show()
		get_node("Cooldown/Label").set_text(str(self.cooldown))
	get_parent().reset_highlighting()
	self.ultimate_flag = false
	self.mid_animation = false
	get_node("BlueGlow").hide()
	self.state = States.PLACED
	get_parent().selected = null
	get_node("AnimatedSprite").play("cooldown")


func push(distance, is_knight=false):
	if get_parent().locations.has(self.coords + distance):
		#if there's something in front, push that
		if get_parent().pieces.has(self.coords + distance):
			get_parent().pieces[self.coords + distance].push(distance)
		animate_move(self.coords + distance)
		set_coords(self.coords + distance)
		self.mid_animation = false
	else:
		delete_self()


#OVERRIDEN FUNCTIONS
func act(new_coords):
	return false

func display_action_range():
	pass
	
func cast_ultimate():
	pass
