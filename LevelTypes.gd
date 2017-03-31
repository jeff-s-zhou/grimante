extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"



const DEFAULT_DEPLOY_TILES = [
Vector2(0, 6), Vector2(1, 6), Vector2(1, 7), Vector2(2, 7), Vector2(3, 7), 
Vector2(3, 8), Vector2(4, 8), Vector2(5, 8), Vector2(5, 9), Vector2(6, 9)
]

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


#do we just want this as something that contains everything aobut a level...
#Okay. so use this instead of the dict structure. So it contains everything, from player pieces, to enemy pieces, to structures

class BaseLevelType:
	var allies = null #maybe by default for the free deploy, it's your most recently used???
	var enemies = null
	var next_level = null
	var instructions = []
	var reinforcements = {}
	var flags = null
	var free_deploy = true
	var deploy_tiles = DEFAULT_DEPLOY_TILES
	var shadow_wall_tiles = []
	var king = null
	var end_conditions = {}
	
	func _init(allies, enemies, next_level=null, extras={}):
		self.allies = allies
		self.enemies = enemies
		self.next_level = next_level
		
		if extras.has("free_deploy"):
			self.free_deploy = extras["free_deploy"]
		if extras.has("instructions"):
			self.instructions = extras["instructions"]
		if extras.has("reinforcements"):
			self.reinforcements = extras["reinforcements"]
		if extras.has("flags"):
			self.flags = extras["flags"]
		if extras.has("shadow_wall_tiles"):
			self.shadow_wall_tiles = extras["shadow_wall_tiles"]
		if extras.has("king"):
			self.king = extras["king"]
			
	func set_end_conditions(conditions):
		self.end_conditions[conditions] = true

	func check_enemy_win(state): #only checks part of the condition. other is in the game loop
		return state.player_pieces.size() == 0
		
	func check_player_win(state):
		return false
		
		


#infinite waves
class RoomSeal extends BaseLevelType:
	func _init(allies, enemies, \
	next_level=null, extras={}).(allies, enemies, next_level, extras):
		pass
		
	func check_player_win(state):
		return state.enemy_pieces.size() == 0


class Defend extends BaseLevelType:
	var Constants = preload("constants.gd").new()
	var num_turns
	func check_player_win(state):
		return state.enemy_pieces.size() == 0 or state.turns_left == 0
	
	func _init(allies, enemies, num_turns, \
	next_level=null, extras={}).(allies, enemies, next_level, extras):
		self.num_turns = num_turns
		set_end_conditions(Constants.end_conditions.Defend)

class Timed extends BaseLevelType:
	var Constants = preload("constants.gd").new()
	var num_turns
	func check_player_win(state):
		return state.enemy_pieces.size() == 0
		
	func check_enemy_win(state): #only checks part of the condition. other is in the game loop
		return state.player_pieces.size() == 0 or state.turns_left == 0
	
	func _init(allies, enemies, num_turns, \
	next_level=null, extras={}).(allies, enemies, next_level, extras):
		self.num_turns = num_turns
		set_end_conditions(Constants.end_conditions.Timed)
		
class MultiTimed extends BaseLevelType:
	var Constants = preload("constants.gd").new()
	
	func check_player_win(state):
		return state.enemy_pieces.size() == 0
		
	func check_enemy_win(state): #only checks part of the condition. other is in the game loop
		return state.player_pieces.size() == 0 or state.turns_left == 0
#	
#class FogOfWar extends BaseLevelType:
#	func check_player_win():
#		pass

