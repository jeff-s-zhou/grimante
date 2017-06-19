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
	var text = ["Enemies can have {Mutations}, which give them additional special effects.", 
	"Press Tab over an enemy with a Mutation to learn about it."]
	add_player_start_rule(tutorial, 0, text, Vector2(2, 5))
	return tutorial
	