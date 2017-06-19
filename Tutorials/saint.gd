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
	var fa_text1 = "The Saint is in your care."
	var text = ["The Saint's Indirect Attack is Purify.", 
	"When it moves to a tile, the Saint {Silences} all adjacent Enemies.", 
	"A silenced Enemy has all its special effects nullified permanently."]
	
	add_forced_action(tutorial, 1, Vector2(3, 4), fa_text1, Vector2(3, 3), fa_text1, text)
	
	text = ["The Saint Inspires other Heroes to Defend."]
	add_forced_action(tutorial, 1, Vector2(2, 4), "", Vector2(2, 2), "", text)
	
	add_forced_action(tutorial, 2, Vector2(2, 2), "", Vector2(0, 2), "")
	text = ["If the Saint reaches the top of the board, she transforms into the Crusader."]
	add_forced_action(tutorial, 2, Vector2(3, 3), "", Vector2(3, 1), "", text)
	
	add_forced_action(tutorial, 3, Vector2(0, 2), "", Vector2(4, 2), "")
	
	fa_text1 = "Unlike the Saint, the Crusader is no pacifist."
	text = ["The Crusader's Direct Attack is Holy Blade.", 
	"The Crusader teleports in front of an Enemy within movement range and silences it, dealing {3} damage."]
	add_forced_action(tutorial, 3, Vector2(3, 1), fa_text1, Vector2(5, 4), fa_text1, text)
	
	add_forced_action(tutorial, 4, Vector2(4, 2), "", Vector2(4, 7), "")
	fa_text1 = "The Crusader is stronger when protecting others."
	text = ["Holy Blade gains {+1 damage for each Hero behind} the Crusader."] 
	add_forced_action(tutorial, 4, Vector2(5, 5), fa_text1, Vector2(3, 4), fa_text1, text)
	
	
	
	return tutorial