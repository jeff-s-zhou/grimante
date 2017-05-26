extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal pressed

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("TextureButton").connect("pressed", self, "is_pressed")

func is_pressed():
	emit_signal("pressed")