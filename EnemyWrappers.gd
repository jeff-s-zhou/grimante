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
	
	var current_turn_index = 0
	
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

	func get_next_summon():
		if self.current_turn_index < self.turn_power_levels.size():
			if self.next_wave != null:
				var wave = self.next_wave
				self.next_wave = null
				self.current_turn_index += 1
				return wave
			else:
				var power_level = self.turn_power_levels[self.current_turn_index]
				var roster = get_piece_roster(self.current_turn_index)
				var modifier_roster = get_modifier_roster(self.current_turn_index)
				self.current_turn_index += 1
				var wave = generator.generate_wave(power_level, roster, modifier_roster)
				return wave
				
		else:
			return null
	
	func preview_next_summon():
		if self.current_turn_index < self.turn_power_levels.size():
			var power_level = self.turn_power_levels[self.current_turn_index]
			var roster = get_piece_roster(self.current_turn_index)
			var modifier_roster = get_modifier_roster(self.current_turn_index)
			var wave = generator.generate_wave(power_level, roster, modifier_roster)
			self.next_wave = wave
			return wave
		else:
			return null
		
	func get_turns_til_next_wave():
		for i in range(self.current_turn_index, self.turn_power_levels.size()):
			if self.turn_power_levels[i] >= self.big_wave_threshold:
				return (i - self.current_turn_index)
		return null


class FiniteCuratedWrapper:
	var current_turn_index = 0
	var turn_power_levels
	var waves
	
	func _init(turn_power_levels, waves):
		self.turn_power_levels = turn_power_levels
		self.waves = waves
		
	func get_next_summon():
		if self.current_turn_index < self.waves.size():
			var wave = self.waves[self.current_turn_index]
			self.current_turn_index += 1
			return wave
		else:
			return null
	
	func preview_next_summon():
		if self.current_turn_index < self.waves.size():
			return self.waves[self.current_turn_index]
		else:
			return null
		
	func get_turns_til_next_wave():
		for i in range(self.current_turn_index, self.turn_power_levels.size()):
			if self.turn_power_levels[i] >= self.big_wave_threshold:
				return (i - self.current_turn_index)
		return null
		
		
class PhasedWrapper:
	var current_phase = null
	var phases = []
	
	func _init(phases):
		self.current_phase = phases[0]
		phases.pop_front()
		self.phases = phases
		
	func get_next_summon():
		var next_summon = self.current_phase.get_next_summon()
		if next_summon == null:
			self.current_phase = self.phases[0]
			self.phases.pop_front()
			var next_summon = self.current_phase.get_next_summon()
		return next_summon
		
	func skip_phase():
		self.current_phase = self.phases[0]
		self.phases.pop_front()
	
	func is_last_phase():
		return self.phases == []
	
	func preview_next_summon():
		self.current_phase.preview_next_summon()
		
	func get_turns_til_next_wave():
		self.current_phase.get_turns_til_next_wave()
		
		
