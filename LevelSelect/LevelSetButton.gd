extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var level_set

signal pressed
	
func initialize(level_set):
	self.level_set = level_set
	get_node("Button").set_text(self.level_set.name.to_upper())
	get_node("Button").connect("pressed", self, "is_pressed")

func is_pressed():
	emit_signal("pressed", self.level_set)