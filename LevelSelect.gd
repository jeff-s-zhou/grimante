extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const levels_prototype = preload("res://Levels.tscn")

const level_button_prototype = null

onready var levels = levels_prototype.instance()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	
	for level in levels.list:
		create_new_level_button(level)
	
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level":levels.sandbox_level_ref})


func create_new_level_button(level):
	var level_button = self.level_button_prototype.instance()

	
func goto_level(level):
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level":level})