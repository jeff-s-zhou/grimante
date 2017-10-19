extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const level_set_button_prototype = preload("res://DesktopLevelSelect/LongTextureLabelButton.tscn")

var levels

onready var screen_size = get_viewport().get_rect().size

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	
	var y_position = 200
	var hard_y_position = 200
	
	self.levels = get_node("/root/global").get_param("level_set")
	
	get_node("BackButton").connect("pressed", self, "back")
	
	for level in self.levels.get_levels():
		create_new_level_button(level, y_position)
		y_position += 76
		
	for level in self.levels.get_hard_levels():
		create_new_level_button(level, hard_y_position)
		hard_y_position += 76

func create_new_level_button(level, y_position):
	var level_button = self.level_set_button_prototype.instance()
	level_button.initialize(level)
	level_button.set_pos(Vector2(screen_size.x/2, y_position))
	level_button.connect("pressed", self, "goto_level")
	add_child(level_button)

	
func goto_level(level):
	print("going to level")
	get_node("/root/global").goto_scene(get_node("/root/global").combat_resource, {"level":level})
	
func back():
	get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn")