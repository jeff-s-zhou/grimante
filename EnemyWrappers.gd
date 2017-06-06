extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


var constants = load("res://constants.gd").new()


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

class FiniteGeneratedWrapper:
	var generator = load("res://EnemyListGenerator.gd").new()
	var next_wave = null
	var turn_power_levels = []
	var big_wave_threshold = 0
	var piece_roster_by_turn = {}
	var modifier_roster_by_turn = {}
	
	func _init(turn_power_levels, piece_roster_by_turn=null, modifier_roster_by_turn=null, big_wave_threshold=1400):
		self.turn_power_levels = turn_power_levels
		self.big_wave_threshold = 1400
		self.piece_roster_by_turn = piece_roster_by_turn
		self.modifier_roster_by_turn = modifier_roster_by_turn
		
	func get_piece_roster(index):
		return constants.FULL_UNIT_ROSTER
		#return self.piece_roster_by_turn(index)
		
	func get_modifier_roster(index):
		return constants.FULL_MODIFIER_ROSTER
		#return self.modifier_roster_by_turn(index)

	func get_next_summon(turn_index):
		if turn_index == 0:
			self.next_wave = null
		
		if turn_index < self.turn_power_levels.size():
			if self.next_wave != null:
				var wave = self.next_wave
				self.next_wave = null
				return wave
			else:
				var power_level = self.turn_power_levels[turn_index]
				var roster = get_piece_roster(turn_index)
				var modifier_roster = get_modifier_roster(turn_index)
				var wave = generator.generate_wave(power_level, roster, modifier_roster)
				return wave
				
		else:
			return null
	
	func preview_next_summon(turn_index):
		if turn_index + 1 < self.turn_power_levels.size():
			var power_level = self.turn_power_levels[turn_index + 1]
			var roster = get_piece_roster(turn_index + 1)
			var modifier_roster = get_modifier_roster(turn_index + 1)
			var wave = generator.generate_wave(power_level, roster, modifier_roster)
			self.next_wave = wave
			return wave
		else:
			return null
		
	func get_turns_til_next_wave(turn_index):
		for i in range(turn_index, self.turn_power_levels.size()):
			if self.turn_power_levels[i] >= self.big_wave_threshold:
				return (i - turn_index)
		return null


class FiniteCuratedWrapper:
	var generator = load("res://EnemyListGenerator.gd").new()
	var waves
	
	func _init(new_waves):
		print(new_waves)
		if typeof(new_waves) == TYPE_DICTIONARY:
			var keys = new_waves.keys()
			self.waves = []
			keys.sort()
			for key in keys:
				self.waves.append(new_waves[key])
		else:
			self.waves = new_waves
		
	func get_next_summon(turn_index):
		print("getting next summon")
		print(turn_index)
		if turn_index < self.waves.size():
			var wave = self.waves[turn_index]
			return wave
		else:
			return null
	
	func preview_next_summon(turn_index):
		if turn_index + 1 < self.waves.size():
			return self.waves[turn_index + 1]
		else:
			return null
		
	func get_turns_til_next_wave(turn_index):
		print(self.waves)
		#so we get the turn index for the next turn
		for i in range(turn_index + 1, self.waves.size()):
			if self.waves[i] != null and !self.waves[i].empty():
				print("getting turns til next wave")
				print(self.waves[i])
				print(i - turn_index)
				return (i - turn_index)
		return null


class FiniteAlteredWrapper extends FiniteCuratedWrapper:
	func _init(turn_power_levels, waves, big_wave_threshold=1400).(turn_power_levels, waves, big_wave_threshold):
		for wave in self.waves:
			generator.alter_wave(wave)
