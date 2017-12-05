extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


#do we just want this as something that contains everything aobut a level...
#Okay. so use this instead of the dict structure. So it contains everything, from player pieces, to enemy pieces, to structures

#NOTE: we keep these stateless for simplicity's sake. state is stored in game
#permanent state is stored in the LevelSet objects

class BaseLevelType:
	var id = null
	var name = ""
	var allies = {}
	var extra_units = null
	var deploy_roster = null
	var enemies = null
	var next_level = null
	var previous_level = null
	var tutorial = null
	var reinforcements = {}
	var traps = {}
	var flags = []
	var free_deploy = true
	var king = null
	var end_conditions = {}
	var is_sub_level = false
	var seamless = false
	var score_guide = {}
	
	func _init(id, name, allies, enemies, next_level=null, extras={}):
		self.id = id
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
		if extras.has("traps"):
			self.traps = extras["traps"]
		if extras.has("flags"):
			self.flags = extras["flags"]
		if extras.has("score_guide"):
			self.score_guide = extras["score_guide"]
		if extras.has("hard"):
			if extras["hard"]:
				self.id += 90000
			
	func set_end_conditions(conditions):
		self.end_conditions[conditions] = true
	
	func get_level():
		return self
		
	func set_next_level(next_level):
		self.next_level = next_level
		
	func is_sub_level():
		return self.is_sub_level
		
	func get_score(turn_count):
		if self.score_guide.has(turn_count):
			return self.score_guide[turn_count]
		else:
			return 5
			
	#ok, the problem is that you can have the same score for multiple turns
	#so instead of "You cleared in 4 turns", we need something like
	#To improve your score, beat on turn 4
	func get_turn_to_improve_score(score):
#		so right now it's turn count -> score
#		what we need to do is find the turn count with a score > score
		var lowest_improved_score = 9999
		var target_turn = 0
		for turn_count in self.score_guide.keys():
			if self.score_guide[turn_count] > score:
				if self.score_guide[turn_count] < lowest_improved_score:
					lowest_improved_score = self.score_guide[turn_count]
					target_turn = turn_count
					
		return target_turn
	
	func get_traps(turn_count):
		var trap_subset = []
		if self.traps.has(turn_count):
			return self.traps[turn_count]

class Timed extends BaseLevelType:
	var Constants = preload("constants.gd").new()
	var num_turns
	
	func _init(id, name, allies, enemies, num_turns, \
	next_level=null, extras={}).(id, name, allies, enemies, next_level, extras):
		self.num_turns = num_turns
		set_end_conditions(Constants.end_conditions.Timed)


class Sandbox extends BaseLevelType:
	var Constants = preload("constants.gd").new()
	
	func _init(id, name, allies, enemies, \
	next_level=null, extras={}).(id, name, allies, enemies, next_level, extras):
		self.flags += ["sandbox", "no_turns"]
		set_end_conditions(Constants.end_conditions.Sandbox)


class MultiLevel:
	var levels
	var name = ""
	var id
	func _init(id, name, levels):
		self.name = name
		self.id = id
		
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


class Trial:
	var levels
	var name = ""
	var id
	
	func _init(id, name, levels):
		self.id = id
		self.name = name
		
		for i in range(0, levels.size()):
			levels[i].seamless = true
		
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
		
	func get_score(turn_count):
		return "N/A"
