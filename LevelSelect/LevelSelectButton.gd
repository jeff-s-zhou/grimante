extends "res://UI/TextureLabelButton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var level

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.y_difference = 9
	
func initialize(level):
	self.level = level
	get_node("Toppings/Name").set_text(self.level.name.to_upper())

func is_pressed():
	print("met here?")
	emit_signal("pressed", self.level)