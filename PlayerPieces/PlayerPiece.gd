extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var States = {"LOCKED":0, "DEFAULT":1, "CLICKED": 2, "PLACED":3, "SELECTED":4}

var overview_description
var attack_description
var passive_description
var ultimate_description

var state = States.PLACED
var coords
var cursor_area

var cooldown = 0
var ultimate_flag = false

var ultimate_used_flag = false

var armor = 0
var movement_value = 1
var attack_bonus = 0

const SHOVE_SPEED = 4

signal invalid_move
signal shake

signal pre_attack(attack_coords)

signal stepped_move_completed

signal targeted

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	
	set_process_input(true)
	self.side = "PLAYER"
	
func set_cooldown(cooldown):
	self.cooldown = cooldown + 1 #offset for the first countdown tick

	
func is_placed():
	return self.state == States.PLACED

func delete_self():
	get_parent().remove_piece(self.coords)
	remove_from_group("player_pieces")
	

func initialize(cursor_area):
	self.cursor_area = cursor_area
	add_to_group("player_pieces")
	
func turn_update():
	set_z(0)
	if self.cooldown > 0:
		pass
	else:
		self.state = States.DEFAULT
		get_node("Cooldown").hide()
		get_node("AnimatedSprite").play("default")
		if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
			self.hovered()

func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords

#ANIMATION FUNCTIONS


#move from tile to tile
func animate_stepped_move(old_coords, new_coords, pathed_range, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var path = []
	var current_pathed_coords = pathed_range[new_coords]
	while(current_pathed_coords.coords != old_coords):
		path.push_front(current_pathed_coords.coords)
		current_pathed_coords = current_pathed_coords.previous
	for coords in path:
		var location = get_parent().locations[coords]
		var new_position = location.get_pos()
		animate_move_to_pos(new_position, speed, trans_type, ease_type)
		yield(get_node("Tween"), "tween_complete")

	if blocking:
		emit_signal("animation_done")


	
func attack_highlight():
	pass
	
func assist_highlight():
	get_node("OverlayLayers/Green").show()


#called when the whole board's highlighting is reset
func reset_highlight(right_click_flag=false):
	get_node("OverlayLayers/White").hide()
	get_node("OverlayLayers/Green").hide()
	if(self.state != States.PLACED):
		get_node("AnimatedSprite").play("default")
		
	if right_click_flag and get_node("CollisionArea").overlaps_area(self.cursor_area):
			self.hovered()
#	else:
#		get_node("AnimatedSprite").play("cooldown")

func reset_prediction_highlight():
	pass
	#get_node("Physicals/AnimatedSprite").show()
	#get_node("Physicals/PredictionLayer").hide()
	

#called on mouse entering the ClickArea
func hover_highlight():
	
	if(self.state != States.PLACED):
		get_node("SamplePlayer2D").play("tile_hover")
		get_node("OverlayLayers/White").show()
	else:
		print("is placed")


#called on mouse exiting the ClickArea
func unhovered():
	get_node("OverlayLayers/White").hide()
	if get_parent().selected == null:
		get_parent().reset_highlighting()
#		
#	elif get_parent().selected == self:
#		reset_highlight()
		

#called when hovered over during player turn		
func hovered():
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	if !self.mid_animation:
		hover_highlight()
	
	if get_parent().selected == null and self.state != States.PLACED:
		display_action_range()



#called when an event happens inside the click area hitput
func input_event(viewport, event, shape_idx):
	
	if event.is_action("select") and !event.is_pressed() and get_node("UltimateBar").ultimate_charging:
		get_node("UltimateBar").end_charging()

	if event.is_action("select") and event.is_pressed() and !self.ultimate_used_flag:
		if get_parent().selected == null and self.state != States.PLACED:
			get_parent().selected = self
			self.state = States.CLICKED
			get_node("BlueGlow").show()
		
		elif get_parent().selected == self:
			get_node("UltimateBar").begin_charging()

		else: #if not selected and not self, then some piece is trying to act on this one
			get_parent().set_target(self)


func deselect():
	self.state = States.DEFAULT
	get_node("BlueGlow").hide()

func select_action_target(target):
	get_parent().reset_highlighting()
	get_parent().reset_prediction()
	get_node("BlueGlow").hide()
	act(target.coords)

#helper function for act
func invalid_move():
	emit_signal("invalid_move")
	self.state = States.DEFAULT
	get_parent().selected = null

#helper function for act

func placed():
	get_node("/root/AnimationQueue").enqueue(self, "animate_placed", false)
	if self.ultimate_flag:
		self.ultimate_used_flag = true
		self.ultimate_flag = false
	self.state = States.PLACED
	self.attack_bonus = 0
	get_parent().selected = null

func animate_placed():
	get_node("OverlayLayers/UltimateWhite").hide()
	if(self.cooldown > 0):
		self.cooldown -= 1
		get_node("Cooldown").show()
		get_node("Cooldown/Label").set_text(str(self.cooldown))
	get_node("AnimatedSprite").play("cooldown")

func dies_to_collision(pusher):
	if pusher != null and pusher.side != self.side:  #if there's a pusher and not on the same side
		return pusher.deadly or self.armor == 0 #if the piece has no armor, or the pusher enemy is deadly

#OVERRIDEN FUNCTIONS
func act(new_coords):
	return false

func display_action_range():
	pass
	
func cast_ultimate():
	pass




