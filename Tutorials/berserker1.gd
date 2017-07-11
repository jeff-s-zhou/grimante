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
	
	var text = ["When you have moved all of your pieces, your turn ends."]
	add_forced_action(tutorial, 1, Vector2(3, 7), Vector2(3, 5), text, true)
	
	text = ["Enemies {move down} 1 tile each turn.", \
	"If an enemy {exits} from the bottom of the board, you {lose}."]
	add_enemy_end_rule(tutorial, 1, text)

	text = ["You have attacked an enemy.", 
	"The Berserker's Direct Attack deals {4} damage to an enemy's Power.", \
	"If an enemy's Power reaches {0}, it is killed."]
	add_forced_action(tutorial, 2, Vector2(3, 5), Vector2(3, 3), text)
	
	text = ["When the Berserker kills an enemy, he moves to its tile. "]
	add_forced_action(tutorial, 3, Vector2(3, 5), Vector2(3, 4), text)
	
	text = ["Clear the board of remaining enemies to win. "]
	add_player_start_rule(tutorial, 4, text)
	
	return tutorial

