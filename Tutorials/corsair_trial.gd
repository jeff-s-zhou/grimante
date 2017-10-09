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
	
	var hint = ["The Corsair attacks adjacent Enemies for 4 damage."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["Whenever the Corsair moves, it shoots a bullet in the opposite direction for {3} damage."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial


func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Corsair can act twice a turn."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial


func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["If the Corsair has already damaged an enemy this turn, it deals 2 less damage to it."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial5_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["Hint: Remember that the Corsair shoots after moving."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial