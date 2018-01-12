extends "res://Tutorials/tutorial.gd"


# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Frost Knight can shove Heroes and enemies 1 tile back in the 6 hex directions."]
	add_hint(tutorial, 1, text, Vector2(3, 7))
	return tutorial
	
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["Enemies shoved off the map on any side except the bottom are killed."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["Shoved enemies are Frozen and Stunned.",
	"Frozen enemies, if killed, shatter and deal {2} damage to all adjacent enemies."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["If a shoved piece lands on an enemy, the enemy dealt {4} damage.",
	"If a shoved piece lands on a Hero, it is damaged."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial5_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["When the Frost Knight moves to a tile, its Indirect Attack freezes enemies in the same {row} of the tile."]
	add_hint(tutorial, 1, text)
	return tutorial
