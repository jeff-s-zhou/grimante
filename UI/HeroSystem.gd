extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var turn_count = 0
var activation_turns = [1, 2, 8, 9, 10]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func update():
	turn_count += 1
	get_node("Label").set_text(str(turn_count))
	if turn_count in activation_turns:
		var player_pieces = get_tree().get_nodes_in_group("player_pieces")
		var unactivated_pieces = []
		for player_piece in player_pieces:
			if !player_piece.ultimate_available_flag:
				unactivated_pieces.append(player_piece)
		
		if unactivated_pieces.size() > 0:
			var random_selector = randi() % unactivated_pieces.size()
			var piece = unactivated_pieces[random_selector]
			piece.ultimate_available_flag = true
			
			var text = get_node("RichTextLabel")
			text.add_text(piece.unit_name + " ")