extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var ASSIST_TYPES = get_node("/root/AssistSystem").ASSIST_TYPES

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(assist_type):
	get_node("AnimatedSprite").show()
	if assist_type == ASSIST_TYPES.attack:
		get_node("AnimatedSprite").play("red")
	elif assist_type == ASSIST_TYPES.defense:
		get_node("AnimatedSprite").play("blue")
	elif assist_type == ASSIST_TYPES.movement:
		get_node("AnimatedSprite").play("yellow")