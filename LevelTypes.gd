extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"



#const DEFAULT_DEPLOY_TILES = [
#Vector2(0, 6), Vector2(1, 6), Vector2(1, 7), Vector2(2, 7), Vector2(3, 7), 
#Vector2(3, 8), Vector2(4, 8), Vector2(5, 8), Vector2(5, 9), Vector2(6, 9)
#]

#const DEFAULT_DEPLOY_TILES = [
#Vector2(0, 5), Vector2(1, 5), Vector2(1, 6), Vector2(2, 6), Vector2(3, 6), 
#Vector2(3, 7), Vector2(4, 7), Vector2(5, 7), Vector2(5, 8), Vector2(6, 8),
#Vector2(0, 99), Vector2(1, 99), Vector2(2, 99), Vector2(3, 99), Vector2(4, 99), #UnitSelectBar Tiles
#Vector2(5, 99), Vector2(6, 99), Vector2(7, 99), Vector2(8, 99)
#]


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


#do we just want this as something that contains everything aobut a level...
#Okay. so use this instead of the dict structure. So it contains everything, from player pieces, to enemy pieces, to structures

class BaseLevelType:
	var name = ""
	var allies = {}
	var extra_units = null
	var deploy_roster = null
	var enemies = null
	var next_level = null
	var previous_level = null
	var tutorial = null
	var reinforcements = {}
	var flags = []
	var free_deploy = true
	var shadow_tiles = []
	var shifting_sands = []
	var king = null
	var end_conditions = {}
	var is_sub_level = false
	
	func _init(name, allies, enemies, next_level=null, extras={}):
		self.name = name
		self.allies = allies
		self.enemies = enemies
		self.next_level = next_level
		
		if extras.has("extra_units"):
			self.extra_units = extras["extra_units"]
		if extras.has("free_deploy"):
			self.free_deploy = extras["free_deploy"]
		if extras.has("tutorial"):
			self.tutorial = extras["tutorial"]
		if extras.has("reinforcements"):
			self.reinforcements = extras["reinforcements"]
		if extras.has("flags"):
			self.flags = extras["flags"]
		if extras.has("shadow_tiles"):
			self.shadow_tiles = extras["shadow_tiles"]
		if extras.has("shifting_sands"):
			self.shifting_sands = extras["shifting_sands"]
		if extras.has("king"):
			self.king = extras["king"]
			
	func set_end_conditions(conditions):
		self.end_conditions[conditions] = true
	
	func get_level():
		return self
		
	func set_next_level(next_level):
		self.next_level = next_level
		
	func is_sub_level():
		return self.is_sub_level


class Timed extends BaseLevelType:
	var Constants = preload("constants.gd").new()
	var num_turns
	
	func _init(name, allies, enemies, num_turns, \
	next_level=null, extras={}).(name, allies, enemies, next_level, extras):
		self.num_turns = num_turns
		set_end_conditions(Constants.end_conditions.Timed)


class Sandbox extends BaseLevelType:
	var Constants = preload("constants.gd").new()
	
	func _init(name, allies, enemies, \
	next_level=null, extras={}).(name, allies, enemies, next_level, extras):
		self.flags += ["sandbox", "no_turns"]
		set_end_conditions(Constants.end_conditions.Sandbox)


class MultiLevel:
	var levels
	func _init(levels):
		for i in range(0, levels.size() - 1):
			levels[i].is_sub_level = true
			levels[i].set_next_level(levels[i+1])
		for i in range(1, levels.size()):
			levels[i].previous_level = levels[i-1]
		self.levels = levels
		
	func get_level():
		return self.levels[0]
		
	func set_next_level(level):
		self.levels[self.levels.size() - 1].set_next_level(level)
	
	func is_sub_level():
		return true

