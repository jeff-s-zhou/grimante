extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func get():
	var tutorial = TutorialPrototype.instance()
	var text = ["This is an Elite Enemy.", 
	"Elite Enemies have powerful effects, so think carefully about how to handle them!"]
	add_player_start_rule(tutorial, 0, text, Vector2(3, 3))
	return tutorial
