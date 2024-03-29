extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var editor_piece_prototype = preload("res://LevelEditor/EditorPiece.tscn")

var enemies = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var roster = get_node("/root/constants").enemy_roster
	var x_pos = 0
	
	for prototype_name in roster.keys():
		var editor_piece = editor_piece_prototype.instance()
		add_child(editor_piece)
		enemies.append(editor_piece)
		editor_piece.initialize_on_bar(prototype_name)
		editor_piece.set_pos(Vector2(24, x_pos))
		x_pos += 110
		
		
func hide():
	for enemy in enemies:
		enemy.set_targetable(false)
	.hide()

func show():
	for enemy in enemies:
		enemy.set_targetable(true)
	.show()
		