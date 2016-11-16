
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var LEVELS = preload("res://LEVELS.gd").new()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	print(LEVELS.Level1)
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level":LEVELS.Level1})


