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
	
	var hint = ["Whenever the Corsair moves, it shoots a bullet in the opposite direction for {3} damage."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair can act twice each turn."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial


func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair's bullets cause Enemies to {Bleed} and take 1 damage after they move."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial


func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair can pull Enemies towards itself with its hook."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial5_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair can also use its hook to pull itself towards Enemies."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial6_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair's hook can target Heroes."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
