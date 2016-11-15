
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var STATES = {"player_turn":0, "enemy_turn":1}
var state = STATES.player_turn
var enemy_waves = []

var enemy_piece_prototype

var grunt_type

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height/2))
	
	
	
	var piece_prototype = load("res://Piece.tscn")
	self.enemy_piece_prototype = load("res://EnemyPiece.tscn")
	
	var berserker_prototype = load("res://PlayerPieceTypes/BerserkerType.tscn")
	var berserker_type = berserker_prototype.instance()
	
	var cavalier_prototype = load("res://PlayerPieceTypes/CavalierType.tscn")
	var cavalier_type = cavalier_prototype.instance()
	
	var grunt_prototype = load("res://EnemyPieceTypes/GruntType.tscn")
	self.grunt_type = grunt_prototype.instance()
	
	get_node("Button").connect("pressed", self, "end_turn")
	
	var piece1 = piece_prototype.instance()
	piece1.initialize(berserker_type)
	get_node("Grid").add_piece(Vector2(0, 7), piece1)
	
	var piece2 = piece_prototype.instance()
	piece2.initialize(cavalier_type)
	get_node("Grid").add_piece(Vector2(1, 7), piece2)
	
	self.enemy_waves = get_enemy_waves()
	deploy_wave()
	
	set_process(true)
	
	get_node("DefenseBar").set_value(100.0)
	
#:TODO make this call get_param for the level initialized with the scene
func get_enemy_waves():
	var first_wave = {Vector2(0, 0): [self.grunt_type], Vector2(4, 2): [self.grunt_type]}
	var second_wave = {Vector2(0, 0): [self.grunt_type]}
	return [first_wave, second_wave]
	
func end_turn():
	self.state = STATES.enemy_turn
	
func _process(delta):
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	if enemy_pieces.size() == 0:
		player_win()
		
	if get_node("DefenseBar").get_value() == 0.0:
		enemy_win()
	
	if self.state == STATES.player_turn:
		pass
	elif self.state == STATES.enemy_turn:
		enemy_pieces.sort_custom(self, "_sort_by_y_axis") #ensures the pieces in front move first
		for enemy_piece in enemy_pieces:
			enemy_piece.turn_update()
			
		self.state = STATES.player_turn
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.turn_update()
			
		#load in new enemies
		deploy_wave()

func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false
		
func deploy_wave():
	if self.enemy_waves.size() > 0:
		var wave = self.enemy_waves[0]
		self.enemy_waves.pop_front()
		for position in wave.keys():
			var enemy_piece_types = wave[position]
			for enemy_piece_type in enemy_piece_types:
				var enemy_piece = enemy_piece_prototype.instance()
				enemy_piece.connect("broke_defenses", self, "damage_defenses")
				enemy_piece.initialize(enemy_piece_type)
				#TODO: push enemies in front away when you deploy more than 1 in same column
				get_node("Grid").add_piece(position, enemy_piece)
		
		
func player_win():
	get_node("/root/global").goto_scene("res://WinScreen.tscn")
	
func enemy_win():
	get_node("/root/global").goto_scene("res://LoseScreen.tscn")
	
func damage_defenses():
	var old_defenses = get_node("DefenseBar").get_value()
	get_node("DefenseBar").set_value(old_defenses - 10)
	


