extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const level_set_button_prototype = preload("res://LevelSelect/LevelSetButton.tscn")


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	
	var y_position = 120
	
	for level_set in get_node("/root/Levels").get_level_sets():
		create_new_level_select(level_set, y_position)
		y_position += 100


func create_new_level_select(level_set, y_position):
	var level_set_button = self.level_set_button_prototype.instance()
	level_set_button.initialize(level_set)
	level_set_button.set_pos(Vector2(60, y_position))
	level_set_button.connect("pressed", self, "goto_level_set")
	add_child(level_set_button)


func goto_level_set(level_set):
	print("going to level set")
	get_node("/root/global").goto_scene("res://LevelSelect/LevelSelect.tscn", {"level_set":level_set})