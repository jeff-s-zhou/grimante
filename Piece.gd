
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

var type

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	get_node("ClickArea").set_monitorable(false)
	get_node("CollisionArea").connect("area_enter", self, "area_entered")
	
	set_process_input(true)
	set_fixed_process(true)
	
func is_placed():
	return self.state == States.PLACED

func delete_self():
	get_parent().pieces.erase(self.coords)
	remove_from_group("player_pieces")
	self.queue_free()

func initialize(type, cursor_area):
	self.cursor_area = cursor_area
	set_z(0)
	add_to_group("player_pieces")
	self.type = type
	add_child(type)
	get_node("PlaceholderSprite").set_opacity(0.0)
	
func turn_update():
	self.type.turn_update()
	self.state = States.DEFAULT
	if(get_node("ClickArea").overlaps_area(self.cursor_area)):
		self.hovered()
	
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
	
func _fixed_process(delta):
	if(is_colliding()):
		print("is colliding!")

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
			if type.act(self.coords, dropped_location.coords, get_parent()):
				self.state = States.PLACED
				get_parent().reset_highlighting()
			else:
				get_parent().reset_highlighting()
				emit_signal("invalid_move")
				self.state = States.DEFAULT


#called when hovered over during player turn		
func hovered():
	emit_signal("description_data", self.type.UNIT_TYPE, self.type.DESCRIPTION)
	if self.state == States.DEFAULT or self.state == States.CLICKED:
		type.hover_highlight()
		type.display_action_range(self.coords, get_parent())


#only undisplay if the unit isn't selected
func unhovered():
	if self.state != States.PLACED:
		type.hover_unhighlight()
	if self.state != States.CLICKED:
		get_parent().reset_highlighting()


func push(distance):
	if get_parent().locations.has(self.coords + distance):
		#if there's something in front, push that
		if get_parent().pieces.has(self.coords + distance):
			get_parent().pieces[self.coords + distance].push(distance)
		
		type.move_to(self.coords, self.coords + distance, get_parent(), SHOVE_SPEED)
		set_coords(self.coords + distance)
	else:
		delete_self()
		
func covering_fire():
	pass
	
func area_entered(area):
	#print(area.get_name())
	print("player piece area entered!")