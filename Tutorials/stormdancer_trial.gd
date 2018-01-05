extends "res://Tutorials/tutorial.gd"


# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Stormdancer throws a Shuriken in each of the 6 hex diagonal directions, dealing 2 damage to the first enemies hit."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Stormdancer can swap positions with Enemies and Allies."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Stormdancer leaves behind a Storm Tile when it moves.", 
	"If an Enemy takes 2 or more damage while standing on a Storm Tile, it is struck by lightning for 2 damage."]
	add_hint(tutorial, 1, text)
	return tutorial