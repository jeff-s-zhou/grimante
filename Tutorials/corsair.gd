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
	var fa_text1 = "The Corsair is ready to buckle some swashes."
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text1)
	fa_text1 = "The Corsair can act twice each turn without any conditions."
	add_forced_action(tutorial, 1, Vector2(3, 5), fa_text1, Vector2(3, 3), fa_text1)
	
	var text = ["Although the Corsair can act twice a turn, he cannot attack while moving."]
	add_player_start_rule(tutorial, 2, text)
	
	fa_text1 = "Move the Corsair adjacent to an enemy to then attack it."
	add_forced_action(tutorial, 2, Vector2(3, 3), fa_text1, Vector2(1, 2), fa_text1)
	add_forced_action(tutorial, 2, Vector2(1, 2), "", Vector2(0, 1), "")
	
	fa_text1 = "The Corsair has one more trick up its sleeve."
	text = [" The Corsair can use its hook to drag enemies close from 2 distance away in a straight line.",
	"It then automatically attacks the enemy."]
	add_forced_action(tutorial, 3, Vector2(1, 2), fa_text1, Vector2(3, 3), fa_text1)
	add_forced_action(tutorial, 3, Vector2(3, 3), fa_text1, Vector2(5, 3), fa_text1, text)
	
	fa_text1 = "The Corsair can also hook allies!"
	text = ["Clear this tutorial before time runs out.", 
	"Hint: The Corsair inspires Movement."]
	add_forced_action(tutorial, 4, Vector2(3, 3), fa_text1, Vector2(3, 5), fa_text1, text)
	return tutorial
