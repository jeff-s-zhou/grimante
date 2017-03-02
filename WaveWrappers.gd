extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


var constants = load("res://constants.gd").new()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


#TODO: make get_next_wave actually just change the index
class FiniteWrapper:
	var waves = null
	var index = 0
	func _init(waves):
		self.waves = waves
		
	func get_next_wave():
		if index < self.waves.size():
			var return_wave = self.waves[index]
			index += 1
			return return_wave
		else:
			return null
			
	func get_remaining_waves_count():
		return self.waves.size() - index
		
	func reset():
		self.index = 0
#		
#	
class FiniteGeneratedWrapper:
	var enemy_wave_generator = load("res://EnemyListGenerator.gd").new()
	var power_curve = null
	var piece_roster = null
	var modifier_roster = null
	var argument_dict = null
	var power_curve_index = 0
	
	func _init(power_curve, piece_roster=constants.FULL_UNIT_ROSTER, \
		modifier_roster=constants.FULL_MODIFIER_ROSTER, argument_dict=null):
		self.power_curve = power_curve
		self.argument_dict = argument_dict
		self.piece_roster = piece_roster
		self.modifier_roster = modifier_roster

	func get_next_wave():
		print("getting next wave in finite")
		print(self.power_curve)
		if power_curve_index < self.power_curve.size():
			var power_level = self.power_curve[power_curve_index]
			power_curve_index += 1
			return enemy_wave_generator.generate_wave(power_level, self.piece_roster, self.modifier_roster)
		else:
			return null
			
	func get_remaining_waves_count():
		return self.power_curve.size() - power_curve_index
		
	func reset():
		self.power_curve_index = 0
#		
#	
class InfiniteGeneratedWrapper:
	var enemy_wave_generator = load("res://EnemyListGenerator.gd").new()
	var power_generator = null
	var piece_roster = null
	var modifier_roster = null
	var argument_dict = null

	func _init(power_generator, piece_roster=constants.FULL_UNIT_ROSTER, \
		modifier_roster=constants.FULL_MODIFIER_ROSTER, argument_dict=null):
		self.power_generator = power_generator
		self.argument_dict = argument_dict
		self.piece_roster = piece_roster
		self.modifier_roster = modifier_roster
		
	func get_next_wave():
		var power_level = self.power_generator.get_next()
		return enemy_wave_generator.generate_wave(power_level, self.piece_roster, self.modifier_roster)
		
	func get_remaining_waves_count():
		return 999
		
	func reset():
		self.power_generator.reset()