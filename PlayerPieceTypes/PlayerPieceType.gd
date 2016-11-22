
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func hover_highlight():
	get_node("AnimatedSprite").play("hover_highlight")
	
func hover_unhighlight():
	get_node("AnimatedSprite").play("default")

func turn_update():
	get_node("AnimatedSprite").play("default")
	
func placed():
	get_node("AnimatedSprite").play("cooldown")
