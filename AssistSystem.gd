extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ASSIST_TYPES = {"attack":1, "movement":2, "invulnerable":3, "finisher":4}

var assist_type = null

var assister = null

var combo_chain = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func reset_combo():
	self.assist_type = null
	self.assister = null
	self.combo_chain = 0
	get_node("/root/AnimationQueue").enqueue(self, "animate_activate_assist", false, [self.assist_type, self.combo_chain])
	
	
func activate_assist(assist_type, assister):
	self.assister = assister
	self.combo_chain += 1
	if self.combo_chain == 5:
		self.assist_type = ASSIST_TYPES.finisher
		var player_pieces = get_tree().get_nodes_in_group("player_pieces")
		for player_piece in player_pieces:
			player_piece.activate_finisher()
	else:
		self.assist_type = assist_type
	get_node("/root/AnimationQueue").enqueue(self, "animate_activate_assist", false, [self.assist_type, self.combo_chain])


func animate_activate_assist(assist_type, combo_chain):
	if assist_type == ASSIST_TYPES.attack:
		get_node("Effect").set_text("Bonus: +1 Attack")
	elif assist_type == ASSIST_TYPES.movement:
		get_node("Effect").set_text("Bonus: +1 Move")
	elif assist_type == ASSIST_TYPES.invulnerable:
		get_node("Effect").set_text("Bonus: Armor")
	elif assist_type == null:
		get_node("Effect").set_text("")
	
	get_node("Count").set_text("Combo: " +  str(combo_chain))


func assist(piece):
	if self.assister != null:
		self.assister.assist(piece)
		

func clear_assist():
	self.combo_chain = 0
	self.assister = null
	self.assist_type = null
	get_node("/root/AnimationQueue").enqueue(self, "animate_activate_assist", false, [self.assist_type, self.combo_chain])


func animate_clear_assist():
	get_node("Effect").set_text("")
	get_node("Count").set_text("Combo: 0")
	

func get_bonus_attack():
	if self.assist_type == ASSIST_TYPES.attack or self.assist_type == ASSIST_TYPES.finisher:
		return 1
	else:
		return 0
	
func get_bonus_movement():
	if self.assist_type == ASSIST_TYPES.movement or self.assist_type == ASSIST_TYPES.finisher:
		return 1
	else:
		return 0
	
func get_bonus_invulnerable():
	return self.assist_type == ASSIST_TYPES.invulnerable or self.assist_type == ASSIST_TYPES.finisher