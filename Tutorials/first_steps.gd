
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
	
	var text = ["Shortcuts: Press {D} or {Right Click} to deselect a Hero.",
	"Press {SPACE} to quickly end your turn, and {R} to quickly restart.",
	"Clear the board of Enemies to win."]
	add_player_start_rule(tutorial, 1, text)
	
	return tutorial

