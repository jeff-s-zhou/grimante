extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal selected(turn_number)

var turn_number

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)

func initialize(turn_number):
	self.turn_number = turn_number
	get_node("Label").set_text(str(self.turn_number + 1))
	
func deselect():
	set_opacity(0.8)
	
func select():
	set_opacity(1.0)
	
func _input_event(viewport, event, shape_idx):
	if get_node("InputHandler").is_select(event):
		emit_signal("selected", self.turn_number)
		