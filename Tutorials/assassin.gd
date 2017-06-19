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
	
	var fa_text1 = "The Assassin is now at your disposal."
	var fa_text2 = "The Assassin attacks by Backstabbing."
	var text = ["The Assassin's Backstab teleports him {1 tile above} the target and deals {2} damage."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text2, text)
	
	fa_text1 = "The Assassin activates a unique ability when he kills an Enemy."
	text = ["After killing an Enemy, the Assassin can act again.", 
	"This can only occur once per turn."]
	
	add_forced_action(tutorial, 2, Vector2(3, 4), fa_text1, Vector2(3, 6), fa_text1, text)
	
	fa_text1 = ""
	text = ["If an Enemy has no other Enemies adjacent to it, Backstab deals {4} damage."]
	add_forced_action(tutorial, 2, Vector2(3, 5), fa_text1, Vector2(2, 5), fa_text1, text)
	
	fa_text1 = "Let's prepare the Assassin's Indirect Attack."
	fa_text2 = "Move the Assassin next to this enemy."
	add_forced_action(tutorial, 3, Vector2(2, 4), fa_text1, Vector2(4, 4), fa_text2) 
	
	text = ["If the Assassin is adjacent to an Enemy that is attacked and not killed, the Assassin automatically attacks it for {1} damage.",
	"And if the Assassin is exhausted, his Indirect Attack allows it to act again!"]
	fa_text1 = "Now send the Cavalier to act."
	fa_text2 = ""
	add_forced_action(tutorial, 3, Vector2(5, 8), fa_text1, Vector2(5, 4), fa_text2, text) 
	
	add_forced_action(tutorial, 3, Vector2(4, 4), "", Vector2(3, 2), "")
	
	text = ["Clear the board this turn."]
	add_player_start_rule(tutorial, 4, text)

	return tutorial