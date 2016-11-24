
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"



const STATES = {"player_turn":0, "enemy_turn":1, "transitioning":2, "enemy_deploying":3, "player_refresh":4}
var state = STATES.player_turn
var enemy_waves = []

const Piece = preload("res://Piece.tscn") 
const BerserkerType = preload("res://PlayerPieceTypes/BerserkerType.tscn")
const CavalierType = preload("res://PlayerPieceTypes/CavalierType.tscn")
const ArcherType = preload("res://PlayerPieceTypes/ArcherType.tscn")
const KnightType = preload("res://PlayerPieceTypes/KnightType.tscn")

const EnemyPiece = preload("res://EnemyPiece.tscn")
const GruntType = preload("res://EnemyPieceTypes/GruntType.tscn")

signal enemy_turn_finished

var _ENEMY_TYPES = preload("res://ENEMY_TYPES.gd").new()

var archer

func _ready():

	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height/2 + 40))
	
	set_z(2)
	
	get_node("Button").connect("pressed", self, "end_turn")
	
	get_node("Button").set_disabled(true)
	
	
	var berserker_type = BerserkerType.instance()
	initialize_piece(berserker_type, 3)
	
	var cavalier_type = CavalierType.instance()
	initialize_piece(cavalier_type, 6)
	
	var archer_type = ArcherType.instance()
	self.archer = initialize_piece(archer_type, 5)
	
	var knight_type = KnightType.instance()
	initialize_piece(knight_type, 4)
	
	self.enemy_waves = get_node("/root/global").get_param("level")
	deploy_wave()
	
	set_process(true)
	
	get_node("DefenseBar").set_value(100.0)
	
func initialize_piece(type, column):
	var piece = Piece.instance()
	piece.connect("invalid_move", self, "handle_invalid_move")
	piece.connect("description_data", self, "display_description")
	piece.initialize(type, get_node("CursorArea"))
	var position = get_node("Grid").get_bottom_of_column(column)
	get_node("Grid").add_piece(position, piece)
	return piece
	
	
func end_turn():
	self.state = STATES.transitioning
	get_node("Button").set_disabled(true)
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.state = player_piece.States.PLACED
	get_node("PhaseShifter").enemy_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	self.state = STATES.enemy_turn
	
func _process(delta):
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	if enemy_pieces.size() == 0 and self.enemy_waves.size() == 0:
		player_win()
		
	if get_node("DefenseBar").get_value() == 0.0:
		enemy_win()
	
	if self.state == STATES.player_turn:
		
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			if !player_piece.is_placed():
				return
		end_turn()
		
	elif self.state == STATES.enemy_turn:
		
		enemy_pieces.sort_custom(self, "_sort_by_y_axis") #ensures the pieces in front move first
		for enemy_piece in enemy_pieces:
			enemy_piece.turn_update()
		
		self.state = STATES.transitioning
		if(get_tree().get_nodes_in_group("enemy_pieces").size() > 0):
			yield(self, "enemy_turn_finished")
		self.state = STATES.enemy_deploying	
		
	elif self.state == STATES.enemy_deploying:
		deploy_wave()
	
	elif self.state == STATES.player_refresh:
		#switch back to player phase
		self.state = STATES.transitioning
		get_node("PhaseShifter").player_phase_animation()
		yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.turn_update()
		self.state = STATES.player_turn
		get_node("Button").set_disabled(false)


func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false
		
func deploy_wave():
	if self.enemy_waves.size() > 0:
		var wave = self.enemy_waves[0]
		self.enemy_waves.pop_front()
		for column in wave.keys():
			var enemy_piece_type = wave[column]
			var enemy_piece = EnemyPiece.instance()
			enemy_piece.connect("broke_defenses", self, "damage_defenses")
			enemy_piece.connect("turn_finished", self, "track_turn_finished")
			enemy_piece.connect("pre_damage", self.archer, "covering_fire")
			
			enemy_piece.initialize(enemy_piece_type)
			#TODO: push enemies in front away when you deploy more than 1 in same column
			var position = get_node("Grid").get_top_of_column(column)
			
			#push any player pieces if they're on the spawn point
			if(get_node("Grid").pieces.has(position)):
				get_node("Grid").pieces[position].push(enemy_piece.get_movement_value())
			get_node("Grid").add_piece(position, enemy_piece)
			
			self.state = STATES.transitioning
			enemy_piece.animate_summon()
			yield(enemy_piece.get_node("AnimationPlayer"), "finished" )
			self.state = STATES.player_refresh
				
	else:
		self.state = STATES.player_refresh
		
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
	
func display_description(name, text):
	pass
	


