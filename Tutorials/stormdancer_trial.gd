extends "res://Tutorials/tutorial.gd"


# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Stormdancer throws a shuriken in each of the 6 hex diagonal directions, dealing 2 damage to the first enemies hit."]
	add_hint(tutorial, 1, text, Vector2(3, 6))
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Stormdancer can swap positions with enemies and Heroes."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Stormdancer leaves behind a Storm when it moves.", 
	"If an enemy takes damage while on a Storm tile, it is struck by lightning for 2 damage.",
	"The Storm is then removed." ]
	add_hint(tutorial, 1, text)
	return tutorial

func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["Remember that lightning is triggered by any source of damage."]
	add_hint(tutorial, 1, text)
	return tutorial