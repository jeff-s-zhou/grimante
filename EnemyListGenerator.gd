extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Fortifier = preload("res://EnemyPieces/FortifierPiece.tscn")
const Grower = preload("res://EnemyPieces/GrowerPiece.tscn")
const Drummer = preload("res://EnemyPieces/DrummerPiece.tscn")

var constants = load("res://constants.gd").new()

var EPSILON = 25

func _ready():
	
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func generate_wave(req_power_level, roster=constants.FULL_UNIT_ROSTER, modifier_roster=constants.FULL_MODIFIER_ROSTER):
	randomize()
	var wave = create_raw_wave(req_power_level, roster, modifier_roster)
	return get_wave_dict_with_positions(wave)

#wave in list form, without coordinates
func create_raw_wave(req_power_level, roster, modifier_roster):
	print("req_power_level is" + str(req_power_level))
	var return_wave = []
	var total_power_level = 0
	while abs(req_power_level - total_power_level) > EPSILON:
		var unit_schematic = null
		var power_level = 9999999
		var capped = false #reaching deploy max
		var iterations = 0
		var lower_bound = 0
		#generate new unit until we find one that doesn't exceed the power cap
		#only break if requirements are met
		while total_power_level + power_level > req_power_level + EPSILON or power_level < lower_bound: 
			unit_schematic = generate_unit(roster, modifier_roster)
			power_level = get_power_level(unit_schematic)
			
			#if return_wave.size() == 4: #can only shove in one more unit
			if return_wave.size() == 6: #can only shove in one more unit
				lower_bound = req_power_level - (total_power_level + EPSILON) #set minimum that the power level has to exceed

			if iterations > 50:
				print("can't get a unit to fit a requirement in the generator")
				break
		
		total_power_level += power_level
		return_wave.append(unit_schematic)
	if return_wave.size() > 6:
		print("have too many units!")
	print("power level is " + str(total_power_level))
	return return_wave
	
func get_wave_dict_with_positions(wave):
	var wave_dict = {}
	for unit_schematic in wave:
		var coords = generate_random_coords()
		while wave_dict.has(coords):
			coords = generate_random_coords()
		wave_dict[coords] = unit_schematic
	return wave_dict

		
func generate_unit(roster, modifier_roster):
	#TODO: implement max_power and min_power checks
	var random_unit_selector = randi() % roster.size()
	var random_unit_prototype = roster[random_unit_selector]
	var health = get_unit_health(random_unit_prototype)
	
	var modifier_selector = randf()
	# chance to just try to find a unit without modifiers
	if modifier_selector < 0.60:
		return {"prototype": random_unit_prototype, "health":health, "modifiers":null}
		
	# chance to try to boost it up with modifiers
	elif modifier_selector >= 0.60 and modifier_selector < 0.94:
		var random_modifier_selector = randi() % modifier_roster.size()
		var random_modifier = modifier_roster[random_modifier_selector]
		return {"prototype": random_unit_prototype, "health":health, "modifiers":[random_modifier]}
	
	# chance to try to boost it up with 2 modifiers
	elif modifier_selector >= 0.94:
		var random_modifier_selector1 = randi() % modifier_roster.size()
		var random_modifier1 = modifier_roster[random_modifier_selector1]
		
		var random_modifier_selector2 = random_modifier_selector1
		while random_modifier_selector2 == random_modifier_selector1:
			random_modifier_selector2 = randi() % modifier_roster.size()
		
		var random_modifier2 = modifier_roster[random_modifier_selector2]
		return {"prototype": random_unit_prototype, "health":health, "modifiers":[random_modifier1, random_modifier2]}
	
	else:
		print("shouldn't reach here in EnemyGenerator")


func get_unit_health(prototype):
	var prob_dist = null
	if prototype == Grunt:
		prob_dist = constants.GRUNT_HEALTH_PROB_DIST
	elif prototype == Fortifier:
		prob_dist = constants.FORTIFIER_HEALTH_PROB_DIST
	elif prototype == Drummer:
		prob_dist = constants.DRUMMER_HEALTH_PROB_DIST
	elif prototype == Grower:
		prob_dist = constants.GROWER_HEALTH_PROB_DIST
	return get_value_from_prob_dist(prob_dist)
	
	
func generate_random_coords(vertical_prob_dist=constants.coords_vertical_prob_dist, horizontal_prob_dist=constants.coords_horizontal_prob_dist):
	var x = get_value_from_prob_dist(horizontal_prob_dist)
	var y = get_value_from_prob_dist(vertical_prob_dist) + constants.y_coords_offsets[x]
	
	return Vector2(x, y)
	
func get_value_from_prob_dist(prob_dist):
	var total_weights = get_total_weights(prob_dist)
	var random_value = total_weights * randf()
	var weight_to_values_dict = get_weight_to_values_dict(prob_dist)
	var sorted_weight_keys = weight_to_values_dict.keys()
	sorted_weight_keys.sort()

	for upper_bound in sorted_weight_keys:
		if random_value <= upper_bound:
			print(weight_to_values_dict[upper_bound])
			return weight_to_values_dict[upper_bound] #returns the health in that range
	

func get_total_weights(prob_dist):
	var total_weights = 0
	for key in prob_dist.keys():
		total_weights += prob_dist[key]
	return total_weights

func get_weight_to_values_dict(prob_dist):
	var new_dict = {}
	var accumulator = 0
	var sorted_keys = prob_dist.keys()
	sorted_keys.sort()
	for key in sorted_keys:
		var weight = prob_dist[key]
		accumulator += weight #we create the distribution so that 0-1 corresponds with 1 health, 1-1.5 corresponds with 2 health, etc.
		
		#we flip the dict so that the upper value of the range is the key, and the health value is the value
		new_dict[accumulator] = key 
	return new_dict

	
func get_power_level(unit_schematic):
	var power_level = 0
	var unit_prototype = unit_schematic["prototype"]
	power_level += constants.UNIT_POWER_LEVELS[unit_prototype]
	
	if unit_schematic["modifiers"] != null:
		var modifiers = unit_schematic["modifiers"]
		for modifier in modifiers:
			power_level += constants.MODIFIER_POWER_LEVELS[modifier]
	
	power_level = power_level * unit_schematic["health"]
	
	return power_level
	
	