extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var editor_hero_piece_prototype = preload("res://LevelEditor/EditorHeroPiece.tscn")

var heroes = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var roster = get_node("/root/constants").hero_roster
	var x_pos = 0
	
	for prototype_name in roster.keys():
		var editor_piece = editor_hero_piece_prototype.instance()
		add_child(editor_piece)
		heroes.append(editor_piece)
		editor_piece.initialize_on_bar(prototype_name)
		editor_piece.set_pos(Vector2(x_pos, 65))
		x_pos += 110
		
	hide()
	
	
func hide():
	for hero in heroes:
		hero.set_targetable(false)
	.hide()

func show():
	for hero in heroes:
		hero.set_targetable(true)
	.show()