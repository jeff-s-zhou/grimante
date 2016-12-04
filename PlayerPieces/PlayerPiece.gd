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
signal animation_done
signal shake

var mid_animation = false #to handle the bug of the clickarea not moving until everything's done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	get_node("ClickArea").set_monitorable(false)
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

func animate_move_to_pos(position, speed):
	self.mid_animation = true
	var distance = get_pos().distance_to(position)
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	

func animate_move(new_coords, speed=200):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed)
	
func attack_highlight():
	pass
	
func assist_highlight():
	print("TODO: implement assist highlighting")
	
func unhighlight():
	pass

#called when an event happens inside the click area hitput
func input_event(viewport, event, shape_idx):

	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and event.pressed \
	and self.state != States.PLACED:
		get_parent().focused = self
		self.state = States.CLICKED
		
	if event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and !event.pressed \
	and self.state != States.PLACED:
		self.state = States.DEFAULT

#processes all events generally
#handles the click release outside of the clickarea
func input(event): 
	if self.state == States.CLICKED \
	and event.type == InputEvent.MOUSE_BUTTON \
	and event.button_index == BUTTON_LEFT \
	and (!event.pressed):
		var dropped_location = get_parent().current_location
		#if act is valid and ends the unit's turn, set state to placed
		if dropped_location != null and dropped_location.coords != self.coords and act(dropped_location.coords): 
			#TODO: I think this is still shitty logic maybe
			get_parent().reset_highlighting()
		#catches the false case of act, which won't jump to the yield return
		else:
			get_parent().focused = null
			get_parent().reset_highlighting()
			emit_signal("invalid_move")
			self.state = States.DEFAULT


func act(new_coords):
	return false

func placed():
	self.mid_animation = false
	self.state = States.PLACED
	get_parent().focused = null
	get_node("AnimatedSprite").play("cooldown")


func unhovered():
	if self.state != States.CLICKED: #only undisplay if the unit isn't selected
		#reset assist highlighting if other piece is focused atm
		if get_parent().focused != null and get_parent().focused != self: 
			print("calling the other hover")
		else:
			get_parent().reset_highlighting()
	if self.state != States.PLACED: #if it's placed, don't reset to default sprite
		hover_unhighlight()
	


#called when hovered over during player turn		
func hovered():
	#if another piece is currently focused, do assist highlighting
	if get_parent().focused != null and get_parent().focused != self:
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

func display_action_range():
	pass


func push(distance):
	if get_parent().locations.has(self.coords + distance):
		#if there's something in front, push that
		if get_parent().pieces.has(self.coords + distance):
			get_parent().pieces[self.coords + distance].push(distance)
		animate_move(self.coords + distance)
		set_coords(self.coords + distance)
		self.mid_animation = false
	else:
		delete_self()
		
func area_entered(area):
	print("player piece area entered!")

func hover_highlight():
	get_node("AnimatedSprite").play("hover_highlight")
	
func hover_unhighlight():
	get_node("AnimatedSprite").play("default")

