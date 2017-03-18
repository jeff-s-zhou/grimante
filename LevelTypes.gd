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

	func check_enemy_win(player_pieces): #only checks part of the condition. other is in the game loop
		return player_pieces.size() == 0
		
	func check_player_win(enemy_pieces):
		return false

	func should_deploy():
		return true
		
	func reset():
		self.enemies.reset()
		
		


#infinite waves
class RoomSeal extends BaseLevelType:
	func _init(allies, enemies, \
	next_level=null, extras={}).(allies, enemies, next_level, extras):
		pass
		
	func check_player_win(enemy_pieces):
		return enemy_pieces.size() == 0
		
	func should_deploy():
		return self.enemies.get_remaining_waves_count() > 0



class ClearWaves extends BaseLevelType:
	func _init(allies, enemies, \
	next_level=null, extras={}).(allies, enemies, next_level, extras):
		pass
	
	func check_player_win(enemy_pieces):
		return enemy_pieces.size() == 0 and self.enemies.get_remaining_waves_count() == 0

	func should_deploy():
		return self.enemies.get_remaining_waves_count() > 0

#
#class Defend extends BaseLevelType:
#	func check_player_win():
#		pass
#
#	
#class FogOfWar extends BaseLevelType:
#	func check_player_win():
#		pass