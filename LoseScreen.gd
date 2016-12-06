extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var level = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	level = get_node("/root/global").get_param("level")
	get_node("Button").connect("pressed", self, "next_level")
	
func next_level():
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level})