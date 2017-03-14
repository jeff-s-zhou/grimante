
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

onready var LEVELS = preload("res://Levels.tscn").instance()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level":LEVELS.sandbox_level_ref})


