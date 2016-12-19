
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var LEVELS = preload("res://Levels.gd").new()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level":LEVELS.Sandbox_Level})
	#OS.set_window_maximized(true)
	print(OS.get_window_size())


