extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


var constants = load("res://constants.gd").new()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


#TODO: make get_next_summon actually just change the index
#class FiniteWrapper:
#	var waves = null
#	var index = 0
#	func _init(waves):
#		self.waves = waves
#		
#	func get_next_summon():
#		if index < self.waves.size():
#			var return_wave = self.waves[index]
#			index += 1
#			return return_wave
#		else:
#			return null
#			
#	func get_remaining_waves_count():
#		return self.waves.size() - index
#		
#	func reset():
#		self.index = 0
		
	
#class FiniteGeneratedWrapper:
#	var enemy_wave_generator = load("res://EnemyListGenerator.gd").new()
#	var power_curve = null
#	var piece_roster = null
#	var modifier_roster = null
#	var argument_dict = null
#	var power_curve_index = 0
#	
#	func _init(power_curve, piece_roster=constants.FULL_UNIT_ROSTER, \
#		modifier_roster=constants.FULL_MODIFIER_ROSTER, argument_dict=null):
#		self.power_curve = power_curve
#		self.argument_dict = argument_dict
#		self.piece_roster = piece_roster
#		self.modifier_roster = modifier_roster
#
#	func get_next_summon():
#		print("getting next wave in finite")
#		print(self.power_curve)
#		if power_curve_index < self.power_curve.size():
#			var power_level = self.power_curve[power_curve_index]
#			power_curve_index += 1
#			return enemy_wave_generator.generate_wave(power_level, self.piece_roster, self.modifier_roster)
#		else:
#			return null
#			
#	func get_remaining_waves_count():
#		return self.power_curve.size() - power_curve_index
#		
#	func reset():
#		self.power_curve_index = 0
#		
#		
class ProcGenPhase:
	var enemy_wave_generator = load("res://EnemyListGenerator.gd").new()
	var piece_roster
	var modifier_roster
	var wave_power_level
	var reinforcement_power_level
	var turn_count = 0
	var max_turn_count = 0
	
	func _init(wave_power_level, reinforcement_power_level, 
	piece_roster=constants.FULL_UNIT_ROSTER, modifier_roster=constants.FULL_MODIFIER_ROSTER, max_turn_count=4):
		self.piece_roster = piece_roster
		self.modifier_roster = modifier_roster
		self.wave_power_level = wave_power_level
		self.reinforcement_power_level = reinforcement_power_level
		self.max_turn_count = max_turn_count
		
	func get_next_summon():
		self.turn_count += 1
		if turn_count == 1: #start of phase, generate a big wave
			return enemy_wave_generator.generate_wave(self.wave_power_level, self.piece_roster, self.modifier_roster)
		elif turn_count == self.max_turn_count + 1:
			return null
		else:
			return enemy_wave_generator.generate_reinforcements(self.reinforcement_power_level, self.piece_roster, self.modifier_roster)
			
	func get_turns_til_finished():
		return self.max_turn_count


class FinalProcGenPhase extends ProcGenPhase:
	var escalation_amount = 0
	
	func _init(wave_power_level, reinforcement_power_level, 
	piece_roster=constants.FULL_UNIT_ROSTER, 
	modifier_roster=constants.FULL_MODIFIER_ROSTER,
	escalation_amount=150).(wave_power_level, reinforcement_power_level, piece_roster, modifier_roster):
		self.escalation_amount = escalation_amount

	func get_next_summon():
		self.turn_count += 1
		if turn_count == 1: #start of phase, generate a big wave
			return enemy_wave_generator.generate_wave(self.wave_power_level, self.piece_roster, self.modifier_roster)
		else:
			return enemy_wave_generator.generate_reinforcements(self.reinforcement_power_level, self.piece_roster, self.modifier_roster)
			self.reinforcement_power_level += self.escalation_amount
			
	func get_turns_til_finished():
		return 999
		
class CuratedPhase:
	var enemies = []
	var turn_count = 0
	var max_turn_count = 0
	
	func _init(max_turn_count=4, enemies=[]):
		self.max_turn_count = max_turn_count
		self.enemies = enemies
		
	func add_wave(wave):
		self.enemies.append({"type":"wave", "enemies":wave})
		
	func add_reinforcements(reinforcements):
		self.enemies.append({"type":"reinforcements", "enemies":reinforcements})
		
	func get_next_summon():
		self.turn_count += 1
		if turn_count == self.max_turn_count + 1:
			return null
		elif turn_count <= self.enemies.size():
			return self.enemies[turn_count-1]
		else:
			return null
			
	func get_turns_til_finished():
		return self.max_turn_count
		


class InfinitePhasedWrapper:
	var phases = []
	var current_phase = null
	
	func _init(phases):
		self.current_phase = phases[0]
		phases.pop_front()
		self.phases = phases

	func get_next_summon():
		var summon = current_phase.get_next_summon()
		if summon == null: #that means this phase is done
			if self.phases != []:
				self.current_phase = self.phases[0]
				self.phases.pop_front()
			else:
				return null
		else:
			return summon
			
		
	func get_turns_til_next_wave():
		if self.phases == []:
			return null
		return self.current_phase.get_turns_til_finished()


class FinitePhasedWrapper:
	var phases = []
	var current_phase = null
	
	func _init(phases):
		self.current_phase = phases[0]
		phases.pop_front()
		self.phases = phases

	func get_next_summon():
		var summon = current_phase.get_next_summon()
		if summon == null: #that means this phase is done
			if self.phases != []:
				self.current_phase = self.phases[0]
				self.phases.pop_front()
			else:
				return null
		else:
			return summon
		
	func get_turns_til_next_wave():
		if self.phases == []:
			return null
		return self.current_phase.get_turns_til_finished()
