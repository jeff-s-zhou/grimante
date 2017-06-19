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

	var fa_text1 = "The Stormdancer is here to help!"
	var fa_text2 = "Move the Stormdancer up."
	var text = ["The Stormdancer leaves behind a Storm whenever it moves.", 
	"The Storm stays on the tile for the rest of the level."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(4, 6), fa_text2, text)
	
	var text =["If an Enemy steps on a Storm Tile, it takes {2} damage."]
	add_enemy_end_rule(tutorial, 1, text)
	
	fa_text1 = "Use the Stormdancer's Direct Attack."
	text = ["The Stormdancer's Tango causes her to {swap positions} with Enemies {or} Heroes within her movement range."]
	add_forced_action(tutorial, 2, Vector2(4, 6), fa_text1, Vector2(3, 4), fa_text1, text)
	
	text = ["The Stormdancer inspires Heroes to {Defend}."]
	add_player_start_rule(tutorial, 3, text)
	
	fa_text1 = ""
	text = ["Unlike other Inspires, Defense is {always triggered} whenever the Stormdancer acts."]
	add_forced_action(tutorial, 3, Vector2(3, 4), fa_text1, Vector2(3, 2), fa_text1, text)
	
	text = ["Defense stays on a Hero until its next turn."]
	add_forced_action(tutorial, 3, Vector2(3, 7), fa_text1, Vector2(3, 4), fa_text1, text)
	
	text = ["When Heroes Defend, they cannot be shoved or killed by any means.",
	"In addition, Defending Heroes can stand on a Reinforcement Hex and cancel it without dying."]
	add_enemy_end_rule(tutorial, 3, text)
	
	text = ["Clear the level before the start of your next turn!",  
	"Hint: Remember that the Stormdancer's Swap doesn't just affect Enemies."]
	add_player_start_rule(tutorial, 4, text)
	
	return tutorial