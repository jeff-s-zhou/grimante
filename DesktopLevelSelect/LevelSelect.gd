extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const level_set_button_prototype = preload("res://DesktopLevelSelect/LongTextureLabelButton.tscn")

var level_set

onready var screen_size = get_viewport().get_rect().size

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	
	var y_position = 200
	var hard_y_position = 200
	
	self.level_set = get_node("/root/global").get_param("level_set")
	
	get_node("Label").set_text(self.level_set.name.to_upper())
	
	get_node("BackButton").connect("pressed", self, "back")
	
	for level in self.level_set.get_levels():
		create_new_level_button(level, y_position)
		y_position += 78
		
#	for level in self.level_set.get_hard_levels():
#		create_new_level_button(level, hard_y_position)
#		hard_y_position += 78

func create_new_level_button(level, y_position):
	var score = get_node("/root/State").get_level_score(level.id, self.level_set.id)
	var level_button = self.level_set_button_prototype.instance()
	level_button.initialize(level, score)
	level_button.set_pos(Vector2(screen_size.x/2, y_position))
	level_button.connect("pressed", self, "goto_level")
	add_child(level_button)

	
func goto_level(level):
	print("going to level")
	get_node("/root/State").request_attempt_session_id()
	get_node("/root/global").goto_scene(get_node("/root/global").combat_resource, {"level":level})
	
func back():
	get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn")