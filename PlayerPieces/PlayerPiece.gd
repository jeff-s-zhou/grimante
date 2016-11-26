extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var States = {"LOCKED":0, "DEFAULT":1, "CLICKED": 2, "PLACED":3}

var state = States.PLACED
var coords
var side = "PLAYER"
var cursor_area

const SHOVE_SPEED = 4

signal invalid_move
signal description_data(unit_name, description)
signal placed

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func is_placed():
	return self.state == States.PLACED

func delete_self():
	get_parent().pieces.erase(self.coords)
	remove_from_group("player_pieces")
	self.queue_free()

func initialize(cursor_area):
	self.cursor_area = cursor_area
	set_z(0)
	add_to_group("player_pieces")
	
func turn_update():
	self.state = States.DEFAULT
	get_node("AnimatedSprite").play("default")
	if(get_node("ClickArea").overlaps_area(self.cursor_area)):
		self.hovered()
	
func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords

func animate_move_to_pos(position, speed):
	var distance = get_pos().distance_to(position)
	var speed = 300
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	

func animate_move(new_coords, speed=200):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed)

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
		
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT and !event.pressed and self.state != States.PLACED:
		self.state = States.DEFAULT


func input(event):
	if self.state == States.CLICKED \
	and event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and (!event.pressed):
		var dropped_location = get_parent().current_location
		if dropped_location != null and dropped_location.coords != self.coords: 
			#if act is valid and ends the unit's turn, set state to placed
			if act(dropped_location.coords):
				self.state = States.PLACED
				get_parent().reset_highlighting()
			else:
				get_parent().reset_highlighting()
				emit_signal("invalid_move")
				self.state = States.DEFAULT
				
				
func act(new_coords):
	return false

#called when hovered over during player turn		
func hovered():
	if self.state == States.DEFAULT or self.state == States.CLICKED:
		hover_highlight()
		display_action_range()
		
func display_action_range():
	pass


#only undisplay if the unit isn't selected
func unhovered():
	if self.state != States.PLACED:
		hover_unhighlight()
	if self.state != States.CLICKED:
		get_parent().reset_highlighting()

func push(distance):
	if get_parent().locations.has(self.coords + distance):
		#if there's something in front, push that
		if get_parent().pieces.has(self.coords + distance):
			get_parent().pieces[self.coords + distance].push(distance)
		
		animate_move(self.coords + distance)
		set_coords(self.coords + distance)
	else:
		delete_self()
		
func area_entered(area):
	print("player piece area entered!")

func hover_highlight():
	get_node("AnimatedSprite").play("hover_highlight")
	
func hover_unhighlight():
	get_node("AnimatedSprite").play("default")

func placed():
	get_node("AnimatedSprite").play("cooldown")
	emit_signal("placed")
