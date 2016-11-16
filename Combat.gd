
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"



const STATES = {"player_turn":0, "enemy_turn":1}
var state = STATES.player_turn
var enemy_waves = []

const Piece = preload("res://Piece.tscn") 
const BerserkerType = preload("res://PlayerPieceTypes/BerserkerType.tscn")
const CavalierType = preload("res://PlayerPieceTypes/CavalierType.tscn")
const ArcherType = preload("res://PlayerPieceTypes/ArcherType.tscn")

const EnemyPiece = preload("res://EnemyPiece.tscn")
const GruntType = preload("res://EnemyPieceTypes/GruntType.tscn")

signal enemy_turn_finished

var _ENEMY_TYPES = preload("res://ENEMY_TYPES.gd").new()

func _ready():

	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2(get_viewport_rect().size.width/2 - 200, get_viewport_rect().size.height/2))
	
	get_node("Button").connect("pressed", self, "end_turn")
	
	var piece1 = Piece.instance()
	var berserker_type = BerserkerType.instance()
	piece1.connect("invalid_move", self, "handle_invalid_move")
	piece1.initialize(berserker_type)
	var position1 = get_node("Grid").get_bottom_of_column(3)
	get_node("Grid").add_piece(position1, piece1)
	
	var piece2 = Piece.instance()
	var cavalier_type = CavalierType.instance()
	piece2.connect("invalid_move", self, "handle_invalid_move")
	piece2.initialize(cavalier_type)
	var position2 = get_node("Grid").get_bottom_of_column(4)
	get_node("Grid").add_piece(position2, piece2)
	
	var piece3 = Piece.instance()
	var archer_type = ArcherType.instance()
	piece3.connect("invalid_move", self, "handle_invalid_move")
	piece3.initialize(archer_type)
	var position3 = get_node("Grid").get_bottom_of_column(5)
	get_node("Grid").add_piece(position3, piece3)
	
	self.enemy_waves = get_node("/root/global").get_param("level")
	deploy_wave()
	
	set_process(true)
	
	get_node("DefenseBar").set_value(100.0)
	
	
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
		yield(self, "enemy_turn_finished")
		deploy_wave()

func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false
		
func deploy_wave():
	if self.enemy_waves.size() > 0:
		var wave = self.enemy_waves[0]
		self.enemy_waves.pop_front()
		for column in wave.keys():
			var enemy_piece_types = wave[column]
			for enemy_piece_type in enemy_piece_types:
				var enemy_piece = EnemyPiece.instance()
				enemy_piece.connect("broke_defenses", self, "damage_defenses")
				enemy_piece.connect("turn_finished", self, "track_turn_finished")
				enemy_piece.initialize(get_physical_type(enemy_piece_type))
				#TODO: push enemies in front away when you deploy more than 1 in same column
				var position = get_node("Grid").get_top_of_column(column)
				
				#push any player pieces if they're on the spawn point
				if(get_node("Grid").pieces.has(position)):
					get_node("Grid").pieces[position].push(enemy_piece.get_movement_value())
				get_node("Grid").add_piece(position, enemy_piece)


func get_physical_type(enemy_piece_type):
	if enemy_piece_type == _ENEMY_TYPES.Grunt:
		return GruntType.instance()
		
		
func player_win():
	get_node("/root/global").goto_scene("res://WinScreen.tscn")
	
func enemy_win():
	get_node("/root/global").goto_scene("res://LoseScreen.tscn")
	
func damage_defenses():
	var old_defenses = get_node("DefenseBar").get_value()
	get_node("DefenseBar").set_value(old_defenses - 10)
	
func track_turn_finished():
	emit_signal("enemy_turn_finished")
	
func handle_invalid_move():
	get_node("InvalidMoveText").set_text("Invalid Move")
	


