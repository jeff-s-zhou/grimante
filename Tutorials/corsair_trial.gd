extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair's Direct Attack, Slash, deals 3 damage to an adjacent Enemy."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["Whenever the Corsair moves, it shoots a bullet in the opposite direction for {2} damage."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["Whenever the Corsair moves, it also Slashes the enemy in front of it."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial


func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair can act twice a turn."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial

	
func get_trial5_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["Hint: Remember that the Corsair shoots while moving."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial