extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_opacity(0)

func animate_show():
	set_opacity(1)
	
func hover():
	get_node("Glow").show()

func unhover():
	get_node("Glow").hide()