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
		var power_level = self.turn_power_levels[self.current_turn_index]
		var roster = get_piece_roster(self.current_turn_index)
		var modifier_roster = get_modifier_roster(self.current_turn_index)
		self.current_turn_index += 1
		var wave = generator.generate_wave(power_level, roster, modifier_roster)
		return wave
		
	func get_turns_til_next_wave():
		for i in range(self.current_turn_index, self.turn_power_levels.size()):
			if self.turn_power_levels[i] >= self.big_wave_threshold:
				return (i - self.current_turn_index)

		return null
