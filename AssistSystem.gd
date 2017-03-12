extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ASSIST_TYPES = {"attack":1, "movement":2, "invulnerable":3, "finisher":4}

var assist_type = null

var combo_chain = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func reset_combo():
	self.combo_chain = 0
	
func activate_assist(assist_type):
	self.combo_chain += 1
	if self.combo_chain == 5:
		var player_pieces = get_tree().get_nodes_in_group("player_pieces")
		for player_piece in player_pieces:
			player_piece.activate_finisher()
	else:
		self.assist_type = assist_type


func clear_assist():
	self.combo_chain = 0
	self.assist_type = null


func get_bonus_attack():
	if self.assist_type == ASSIST_TYPES.attack:
		return 1
	else:
		return 0
	
func get_bonus_movement():
	if self.assist_type == ASSIST_TYPES.movement:
		return 1
	else:
		return 0
	
func get_bonus_invulnerable():
	return self.assist_type == ASSIST_TYPES.invulnerable