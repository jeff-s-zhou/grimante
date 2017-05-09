extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var roster = get_node("/root/constants").player_roster
	var x_pos = 0
	
	for prototype_name in roster.keys():
		add_child(editor_piece)
		editor_piece.set_pos(Vector2(x_pos, 34))
		x_pos += 110
		