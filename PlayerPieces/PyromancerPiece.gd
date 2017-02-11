extends "PlayerPiece.gd"

const DEFAULT_WILDFIRE_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 1
const UNIT_TYPE = "Pyromancer"

var backstab_damage = DEFAULT_WILDFIRE_DAMAGE setget , get_wildfire_damage

const OVERVIEW_DESCRIPTION = """
"""

const ATTACK_DESCRIPTION = """
"""

const PASSIVE_DESCRIPTION = """"""

const ULTIMATE_DESCRIPTION = """"""

var pathed_range

func _ready():
	self.armor = 1
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
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, self.movement_value + 1], "ENEMY")
	return unfiltered_range
	
func unhovered():
	if get_parent().selected == null:
		get_parent().hide_pyromancer_selectors()
	.unhovered()

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()

func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()


func act(new_coords):
	get_parent().hide_pyromancer_selectors()
	if _is_within_movement_range(new_coords):
		
		var args = [self.coords, new_coords, self.pathed_range, 350]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		get_node("/root/Combat").handle_archer_ultimate(new_coords)
		backstab(new_coords)
	else:
		invalid_move()
		

func backstab(new_coords):
	pass


func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
