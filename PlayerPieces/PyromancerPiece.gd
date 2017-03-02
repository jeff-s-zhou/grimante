extends "PlayerPiece.gd"

const DEFAULT_WILDFIRE_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_ARMOR_VALUE = 1
const UNIT_TYPE = "Pyromancer"

var wildfire_damage = DEFAULT_WILDFIRE_DAMAGE setget , get_wildfire_damage

const OVERVIEW_DESCRIPTION = """
"""

const ATTACK_DESCRIPTION = """
"""

const PASSIVE_DESCRIPTION = """"""

const ULTIMATE_DESCRIPTION = """"""

var pathed_range

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION


func get_wildfire_damage():
	return self.attack_bonus + DEFAULT_WILDFIRE_DAMAGE


func get_movement_range():
	self.pathed_range = get_parent().get_pathed_range(self.coords, self.movement_value)
	return self.pathed_range.keys()
	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, 3], "ENEMY")
	return unfiltered_range

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()

func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()


func act(new_coords):
	if _is_within_movement_range(new_coords):
		
		var args = [self.coords, new_coords, self.pathed_range, 350]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		#placed()
	elif _is_within_attack_range(new_coords):
		bomb(new_coords)
	elif _is_within_ally_shove_range(new_coords):
		initiate_shove(new_coords)
		placed()
	else:
		invalid_move()
		

func bomb(new_coords):
	var action = get_new_action(new_coords)
	action.add_call("set_burning", [true])
	action.add_call("attacked", [self.wildfire_damage])
	action.execute()
	
	var nearby_enemy_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	var nearby_enemy_range_filtered = []
	for coords in nearby_enemy_range:
		if !get_parent().pieces[coords].burning:
			nearby_enemy_range_filtered.append(coords)
	if nearby_enemy_range_filtered.size() > 0:
		var random_index = randi() % nearby_enemy_range_filtered.size()
		var spread_coords = nearby_enemy_range_filtered[random_index]
		bomb(spread_coords)
		

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
