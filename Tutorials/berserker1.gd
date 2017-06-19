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
	
	var text = ["Clear the board of enemies to win."]
	add_player_start_rule(tutorial, 1, text)
	
	var text = ["When all of your pieces have moved, your turn ends."]
	var fa_text1 = "Click on the Berserker to select it."
	var fa_text2 = "Click on this tile to move the Berserker here."
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text2, text)
	
	text = ["Enemies move down one tile each turn.", \
	"If an enemy [b]exits from the bottom[/b] of the board, you [b]lose[/b]."]
	add_enemy_end_rule(tutorial, 1, text)

	text = ["The Berserker's Direct Attack deals 4 damage to an enemy's Power.", \
	"If an enemy's Power reaches 0, it is killed."]
	fa_text1 = "Select the Berserker"
	fa_text2 = "Select the Enemy to attack it."
	add_forced_action(tutorial, 2, Vector2(3, 5), fa_text1, Vector2(3, 3), fa_text2, text)
	
	text = ["When the Berserker kills an enemy, it moves to its tile. "]
	fa_text1 = "Kill the Enemy"
	fa_text2 = ""
	add_forced_action(tutorial, 3, Vector2(3, 5), fa_text1, Vector2(3, 4), fa_text2, text)
	
	text = ["Clear the board of remaining enemies to win. "]
	add_player_start_rule(tutorial, 4, text)
	
	return tutorial

