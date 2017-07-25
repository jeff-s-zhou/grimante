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
	var text = ["Heroes can now {Inspire} other Heroes.", 
	"After killing an Enemy, a Hero gives a bonus effect to the {next Hero that acts}."]
	add_player_start_rule(tutorial, 1, text)
	
	text = ["The Berserker inspires allies to {Attack}.", 
	"Whenever the Berserker kills an enemy, the next Hero that acts receives {+1 to all damage} dealt."]
	add_forced_action(tutorial, 1, Vector2(1, 6), Vector2(1, 4), text)
	
	add_forced_action(tutorial, 1, Vector2(5, 8), Vector2(5, 3))
	
	text = ["The Cavalier inspires allies to {Move}.",  
	"Whenever the Cavalier kills an enemy, the next Hero gains  {+1 range to its movement}."]
	add_forced_action(tutorial, 2, Vector2(5, 3), Vector2(0, 3), text)
	
	text = ["The Assassin inspires Attack, and the Archer inspires Movement.",
	"Press Tab over a Hero to see what it Inspires."]
	
	add_player_start_rule(tutorial, 3, text)

	return tutorial