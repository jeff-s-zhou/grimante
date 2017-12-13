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
	var text = ["Heroes can now {Inspire} other Heroes.", 
	"After a Hero kills an Enemy, the next Hero that acts receives a {bonus effect}.",
	"The Berserker {Inspires Attack}(Red Heart Icon).",
	"After the Berserker kills an enemy, the next Hero that acts deals {+1 damage}."]
	add_player_start_rule(tutorial, 1, text, Vector2(4, 7))
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Cavalier {Inspires Movement}(Yellow Heart Icon).", 
	"After the Cavalier kills an enemy, the next Hero that acts gains {+1 movement range}."]
	add_player_start_rule(tutorial, 1, text, Vector2(3, 6))
	return tutorial
	
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Frost Knight {Inspires Armor}(Blue Heart Icon).", 
	"Unlike other Inspires, {Inspire Armor} does not require a kill to trigger.",
	"After the Frost Knight acts, the next Hero that acts gains {Shield}."]
	add_player_start_rule(tutorial, 1, text, Vector2(3, 6))
	return tutorial
	
	
func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Inspire Type is also displayed on the Hero Information Screen."]
	
	add_player_start_rule(tutorial, 1, text)

	return tutorial