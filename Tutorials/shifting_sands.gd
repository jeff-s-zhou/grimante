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
	var text = ["This is Shifter Tile.", "After a Hero or Enemy moves on a Shifter tile, they are shoved in the direction the tile is facing."]
	add_player_start_rule(tutorial, 1, text, Vector2(3, 5))
	
	text = ["After being stepped on, a Shifter Tile rotates clockwise."]
	add_forced_action(tutorial, 1, Vector2(3, 7), "", Vector2(3, 5), "", text)
	return tutorial
	