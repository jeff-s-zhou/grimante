
extends Node2D


# member variables here, example:
# var a=2
# var b="textvar"

const levels_prototype = preload("res://Levels.tscn")

onready var levels = levels_prototype.instance()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level":levels.sludge_lord()})


