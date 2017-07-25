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

	var text = ["The Assassin's Backstab teleports him 1 tile above the target and deals {1} damage."]
	add_forced_action(tutorial, 1, Vector2(3, 7), Vector2(3, 5), text)
	
	text = ["After killing an Enemy, the Assassin can act again."]
	
	add_forced_action(tutorial, 2, Vector2(3, 4), Vector2(3, 6), text)
	
	text = ["If an Enemy has no other Enemies adjacent to it, Backstab deals {3} damage."]
	add_forced_action(tutorial, 2, Vector2(3, 5), Vector2(2, 5), text)
	
	add_forced_action(tutorial, 2, Vector2(2, 4), Vector2(4, 5)) 
	
	text = ["If the Assassin is adjacent to an Enemy that is attacked and {not killed}, the Assassin automatically attacks it for {1} damage."]

	add_forced_action(tutorial, 3, Vector2(5, 8), Vector2(5, 5), text) 
	
	add_forced_action(tutorial, 3, Vector2(4, 5), Vector2(3, 4))
	
	text = ["If the Assassin kills an Enemy in any way, it can act again."]
	add_forced_action(tutorial, 3, Vector2(3, 7), Vector2(3, 4), text)
	
	add_forced_action(tutorial, 3, Vector2(3, 3), Vector2(2, 4))
	

	return tutorial