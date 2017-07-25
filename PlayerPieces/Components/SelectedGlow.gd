extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var ASSIST_TYPES = get_node("/root/Combat/AssistSystem").ASSIST_TYPES

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(assist_type):
	if assist_type == ASSIST_TYPES.attack:
		get_node("Sprite").play("red")
	elif assist_type == ASSIST_TYPES.movement:
		get_node("Sprite").play("yellow")
	else:
		get_node("Sprite").play("default")