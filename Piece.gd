
extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var States = {"LOCKED":0, "DEFAULT":1, "CLICKED": 2, "PLACED":3}

var state = States.DEFAULT
var coords
var side = "PLAYER"

signal invalid_move

var type

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	get_node("ClickArea").connect("mouse_enter", self, "display_action_range")
	get_node("ClickArea").connect("mouse_exit", self, "undisplay_action_range")
	set_process_input(true)


func initialize(type):
	add_to_group("player_pieces")
	self.type = type
	add_child(type)
	var texture = load(type.texture_path)
	get_node("Sprite").set_texture(texture)
	
func turn_update():
	self.state = States.DEFAULT
	
func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	pass
	
func attack_highlight():
	pass
	
func unhighlight():
	pass

func input_event(viewport, event, shape_idx):
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT and event.pressed and self.state != States.PLACED:
		self.state = States.CLICKED


func input(event):
	if self.state == States.CLICKED:
		if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and !event.pressed:
			var dropped_location = get_parent().current_location
			if dropped_location != null: 
				#if act is valid and ends the unit's turn, set state to placed
				if type.act(self.coords, dropped_location.coords, get_parent()):
					self.state = States.PLACED
				else:
					emit_signal("invalid_move")
					self.state = States.DEFAULT


#called when hovered over during player turn		
func display_action_range():
	if self.state == States.DEFAULT or self.state == States.CLICKED:
		type.display_action_range(self.coords, get_parent())


#only undisplay if the unit isn't selected
func undisplay_action_range():
	if self.state != States.CLICKED:
		get_parent().reset_highlighting()


func push(distance):
	type.move_to(self.coords, self.coords + distance, get_parent())
	set_coords(self.coords + distance)
	