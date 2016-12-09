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

const SHOVE_SPEED = 4

signal invalid_move
signal description_data(unit_name, description)
signal hide_description
signal animation_done
signal shake

signal targeted

var mid_animation = false #to handle the bug of the clickarea not moving until everything's done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	set_process_input(true)
	set_process(true)

	
func is_placed():
	return self.state == States.PLACED

func delete_self():
	get_parent().pieces.erase(self.coords)
	remove_from_group("player_pieces")
	self.queue_free()

func initialize(cursor_area):
	self.cursor_area = cursor_area
	set_z(-1)
	add_to_group("player_pieces")
	
func turn_update():
	self.state = States.DEFAULT
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

func animate_move(new_coords, speed=200, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed, trans_type, ease_type)
	
func attack_highlight():
	pass
	
func assist_highlight():
	get_node("AnimatedSprite").play("hover_highlight")
	
func unhighlight():
	if(self.state != States.PLACED):
		get_node("AnimatedSprite").play("default")
	else:
		get_node("AnimatedSprite").play("cooldown")
		
func hover_highlight():
	get_node("AnimatedSprite").play("hover_highlight")
	

func unhovered():
	emit_signal("hide_description")
	if self.state != States.CLICKED: #only undisplay if the unit isn't selected
		#reset assist highlighting if other piece is selected atm
		if get_parent().selected != null and get_parent().selected != self: 
			print("calling the other unhover")
		else:
			get_parent().reset_highlighting()
	unhighlight()

#called when hovered over during player turn		
func hovered():
	emit_signal("description_data", self.UNIT_TYPE, self.DESCRIPTION)
	
	#if another piece is currently selected, do assist highlighting
	if get_parent().selected != null and get_parent().selected != self:
		print("calling the other hover")
	else:
		if self.state == States.DEFAULT or self.state == States.CLICKED:
			if self.mid_animation == false: #to handle the bug of the clickarea not moving until everything's done
				hover_highlight()
				display_action_range()
			else:
				print("met3")
		else:
			print("met2")


#called when an event happens inside the click area hitput
func input_event(viewport, event, shape_idx):
	if event.is_action("select") and event.is_pressed():
		if get_parent().selected == null and self.state != States.PLACED:
			get_parent().selected = self
			self.state = States.CLICKED
			hovered()
		elif get_parent().selected != self: #if not selected, then some piece is trying to act on this one
			get_parent().set_target(self)


func deselect():
	self.state = States.DEFAULT

func select_action_target(target):
	
	if target.coords == self.coords:
		invalid_move()
	else:
		act(target.coords)

#helper function for act
func invalid_move():
	emit_signal("invalid_move")
	self.state = States.DEFAULT
	get_parent().selected = null

#helper function for act
func placed():
	get_parent().reset_highlighting()
	self.mid_animation = false
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
