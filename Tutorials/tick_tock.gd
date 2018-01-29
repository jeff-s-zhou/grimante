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
	
	var text = ["Special enemies with abilities have appeared!", 
	"Click on them to read what they do."]
	add_enemy_end_rule(tutorial, 1, text)

	return tutorial