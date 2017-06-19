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
	
	var text = ["You've learned how to use the Berserker's {Direct Attack}.", \
	"However, that's not all the Berserker can do."]
	add_player_start_rule(tutorial, 1, text)
	
	var text = ["When the Berserker moves to an empty tile, he uses his {Indirect Attack}, Ground Slam.", "Ground Slam deals 2 damage to adjacent enemies."]
	var fa_text1 = "Move the Berserker next to these enemies."
	var fa_text2 = ""
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text2, text)
	
	text = ["The Berserker's Indirect Attack {Stuns} enemies.", \
	"The Stun Effect prevents enemies from moving their next turn.", 
	"However, the effect is {cancelled} if an enemy is attacked while stunned."]
	fa_text1 = "Attack these High Power enemies."
	fa_text2 = ""
	add_forced_action(tutorial, 2, Vector2(3, 5), fa_text1, Vector2(3, 3), fa_text2, text)

	text = ["Clear the board."]
	add_player_start_rule(tutorial, 3, text)
	
	return tutorial