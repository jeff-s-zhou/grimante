extends "res://Tutorials/tutorial.gd"


# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Frost Knight can shove Heroes and Enemies 1 tile back."]
	add_hint(tutorial, 1, text)
	return tutorial
	
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["Enemies shoved off the map on any side except the bottom are killed."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["Shoved enemies are Frozen and Stunned.",
	"Frozen Enemies, if killed, shatter and deal {2} damage to all adjacent Enemies."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["If a shoved Enemy lands on a Piece, that Piece is killed if it is not Shielded."]
	add_hint(tutorial, 1, text)
	return tutorial
	
func get_trial5_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["When the Frost Knight moves to a tile, her Indirect Attack freezes Enemies in the same {row} of the tile."]
	add_hint(tutorial, 1, text)
	return tutorial
