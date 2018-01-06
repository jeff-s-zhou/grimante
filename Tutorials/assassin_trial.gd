extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["The Assassin is now at your disposal.",
	"The Assassin's Backstab teleports it 1 tile above the target and deals {1} damage."]
	add_hint(tutorial, 1, text, Vector2(3, 7))
	
	text = ["After killing an Enemy, the Assassin can act again."]
	add_hint(tutorial, 2, text)
	
	text = ["If an Enemy has no other Enemies adjacent to it, Backstab deals {3} damage."]
	add_hint(tutorial, 3, text)
	
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()

	var text = ["If the Assassin is adjacent to an Enemy that is attacked and {not killed}, the Assassin automatically attacks it for {1} damage."]
	add_hint(tutorial, 1, text)

	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()

	var text = ["Remember that the Assassin can act again after killing an enemy in any way."]
	add_hint(tutorial, 1, text)

	return tutorial