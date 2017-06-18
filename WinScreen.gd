extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar

var level = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	level = get_node("/root/global").get_param("level")
	get_node("LevelSelectButton").connect("pressed", self, "level_select")
	if level == null:
		get_node("Button").hide()
		get_node("Label").set_text("You beat the game. Thanks for playing and don't forget to give feedback!")
	else:
		
		get_node("Button").connect("pressed", self, "next_level")
	
func next_level():
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level})
	
func level_select():
	get_node("/root/global").goto_scene("res://LevelSelect/LevelSelect.tscn")