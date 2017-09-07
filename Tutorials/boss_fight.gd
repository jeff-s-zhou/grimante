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
	var text = ["This level has a {Boss}.",
	"If you beat the Boss, you beat the level.",
	"Bosses are sturdy. {1} damage attacks are {ignored}, and {all other attacks} deal {1} damage."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial