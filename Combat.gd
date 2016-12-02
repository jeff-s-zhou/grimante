
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"



const STATES = {"player_turn":0, "enemy_turn":1, "transitioning":2, "game_start":3}
var state = STATES.game_start
var enemy_waves = []

const BerserkerPiece = preload("res://PlayerPieces/BerserkerPiece.tscn")
const CavalierPiece = preload("res://PlayerPieces/CavalierPiece.tscn")
const ArcherPiece = preload("res://PlayerPieces/ArcherPiece.tscn")
const KnightPiece = preload("res://PlayerPieces/KnightPiece.tscn")

const GruntPiece = preload("res://EnemyPieces/GruntPiece.tscn")

signal enemy_turn_finished
signal wave_deployed

var archer

func _ready():

	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2((get_viewport_rect().size.width - 220)/2, get_viewport_rect().size.height/2 + 40))
	
	get_node("Button").connect("pressed", self, "end_turn")
	
	get_node("Button").set_disabled(true)
	
	var berserker_piece = BerserkerPiece.instance()
	initialize_piece(berserker_piece, 3)
	
	var cavalier_piece = CavalierPiece.instance()
	initialize_piece(cavalier_piece, 4)
#	
	var archer_piece = ArcherPiece.instance()
	initialize_piece(archer_piece, 6)
	
	var knight_piece = KnightPiece.instance()
	initialize_piece(knight_piece, 5)
	
	self.enemy_waves = get_node("/root/global").get_param("level")
	
	#we store the initial wave count as the first value in the array
	var initial_waves = self.enemy_waves[0]
	self.enemy_waves.pop_front()
	
	get_node("WavesDisplay/WavesLabel").set_text(str(self.enemy_waves.size()))
	
	for i in range(0, initial_waves):
		if self.enemy_waves.size() > 0:
			deploy_wave()
			yield(self, "wave_deployed")

	get_node("PhaseShifter").player_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.turn_update()
	
	self.state = STATES.player_turn
	get_node("Button").set_disabled(false)
	set_process(true)
	
	
func initialize_piece(piece, column):
	piece.connect("invalid_move", self, "handle_invalid_move")
	piece.connect("description_data", self, "display_description")
	piece.connect("shake", self, "screen_shake")
	piece.initialize(get_node("CursorArea"))
	var position = get_node("Grid").get_bottom_of_column(column)
	get_node("Grid").add_piece(position, piece)
	
	
func end_turn():
	
	self.state = STATES.transitioning
	get_node("Button").set_disabled(true)
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.state = player_piece.States.PLACED
	get_node("PhaseShifter").enemy_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	get_node("ComboSystem").player_turn_ended()
	self.state = STATES.enemy_turn
	
func _process(delta):
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	if enemy_pieces.size() == 0 and self.enemy_waves.size() == 0:
		player_win()

	if self.state == STATES.player_turn:
		
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			if !player_piece.is_placed():
				return
		end_turn()
		
	elif self.state == STATES.enemy_turn:
		enemy_phase(enemy_pieces)
		self.state = STATES.transitioning

	elif self.state == STATES.transitioning:
		pass
		
		
func enemy_phase(enemy_pieces):
	enemy_pieces.sort_custom(self, "_sort_by_y_axis") #ensures the pieces in front move first
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_update()

	if(get_tree().get_nodes_in_group("enemy_pieces").size() > 0):
		yield(self, "enemy_turn_finished")
	print("calling deploy_wave from enemy_phase")
	if self.enemy_waves.size() > 0:
			deploy_wave()
			yield(self, "wave_deployed")
	
	get_node("PhaseShifter").player_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.turn_update()
	
	self.state = STATES.player_turn
	get_node("Button").set_disabled(false)



func screen_shake():
	get_node("ShakeCamera").shake(0.5, 30, 4)


func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false
		
func deploy_wave():

	var wave = self.enemy_waves[0]
	self.enemy_waves.pop_front()
	for column in wave.keys():
		var enemy_piece = wave[column]
		enemy_piece.connect("broke_defenses", self, "damage_defenses")
		enemy_piece.connect("turn_finished", self, "track_turn_finished")

		#TODO: push enemies in front away when you deploy more than 1 in same column
		var position = get_node("Grid").get_top_of_column(column)
		
		#push any player pieces if they're on the spawn point
		if(get_node("Grid").pieces.has(position)):
			get_node("Grid").pieces[position].push(enemy_piece.get_movement_value())
		get_node("Grid").add_piece(position, enemy_piece)
		
		enemy_piece.animate_summon()
		yield(enemy_piece.get_node("AnimationPlayer"), "finished" )
		get_node("WavesDisplay/WavesLabel").set_text(str(self.enemy_waves.size()))

	emit_signal("wave_deployed")

func player_win():
	get_node("/root/global").goto_scene("res://WinScreen.tscn")
	
func enemy_win():
	get_node("/root/global").goto_scene("res://LoseScreen.tscn")
	
func damage_defenses():
	enemy_win()
	
func track_turn_finished():
	emit_signal("enemy_turn_finished")
	
func handle_invalid_move():
	get_node("InvalidMoveText").set_text("Invalid Move")
	
func display_description(name, text):
	pass
	


