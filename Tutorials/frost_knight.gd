extends "res://Tutorials/tutorial.gd"


# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func get():
	var tutorial = TutorialPrototype.instance()
	var fa_text1 = "The Frost Knight is at your command."
	var text = ["The Frost Knight can shove Enemies and Heroes.", 
	"Shoved Enemies are {Frozen} and {Stunned}."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 6), fa_text1, text)
	
	fa_text1 = "Let's attack the Frozen Enemy and see what happens."
	text = ["Frozen Enemies, if killed, shatter and deal {2} damage to all adjacent Enemies.",  
	"NOTE: Being Burned by the Pyromancer cancels out being Frozen, and vice versa."]
	add_forced_action(tutorial, 1, Vector2(2, 6), fa_text1, Vector2(3, 5), fa_text1, text)
	
	add_forced_action(tutorial, 2, Vector2(2, 6), "", Vector2(2, 5), "")
	
	fa_text1 = "The Frost Knight can only move in the 6 hexagonal directions, even when Inspired."
	add_forced_action(tutorial, 2, Vector2(3, 6), fa_text1, Vector2(5, 6), fa_text1)
	
	text = ["Enemies shoved off the map on any side except the bottom are killed."]
	add_forced_action(tutorial, 3, Vector2(5, 6), "", Vector2(6, 6), "", text)
	
	text = ["The Frost Knight Inspires Defense."]
	add_forced_action(tutorial, 3, Vector2(2, 6), "", Vector2(2, 5), "", text)
	
	text = ["When the Frost Knight moves to a tile, her Indirect Attack freezes Enemies in the same {row} of the tile.",
	"Clear the board!"]
	add_forced_action(tutorial, 4, Vector2(6, 6), "", Vector2(5, 6), "", text)
	return tutorial