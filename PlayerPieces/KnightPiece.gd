
extends "PlayerPiece.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const DEFAULT_MOVEMENT_VALUE = 1

const UNIT_TYPE = "Knight"
const DESCRIPTION = """Armor: 2
Movement: 1 range step
Attack: Shove. 1 range, pushes target back and also pushes targets behind them. Can push friendly units and not KO them.
"""
	
func _ready():
	self.armor = 1
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.hover_description = DESCRIPTION
	
func get_movement_range():
	return get_parent().get_range(self.coords)
	
func get_enemy_shove_range():
	return get_parent().get_range(self.coords, [1, 2], "ENEMY")
	
func get_ally_shove_range():
	return get_parent().get_range(self.coords, [1, 2], "PLAYER")

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range() + get_enemy_shove_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
		
	var ally_action_range = get_ally_shove_range()
	for coords in ally_action_range:
		get_parent().get_at_location(coords).assist_highlight()


func _is_within_shove_range(new_coords):
	var shove_range = get_enemy_shove_range() + get_ally_shove_range()
	return new_coords in shove_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()


func act(new_coords):
	if _is_within_movement_range(new_coords):
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", true, [new_coords])
		set_coords(new_coords)
		placed()
	elif _is_within_shove_range(new_coords):
		get_node("/root/Combat").handle_archer_ultimate(new_coords)
		var distance = new_coords - self.coords
		push(distance)
		placed()
		get_node("/root/Combat").handle_assassin_passive(new_coords)
	else:
		invalid_move()


func predict(new_coords):
	if _is_within_shove_range(new_coords):
		pass
		#get_parent().pieces[new_coords].predict(BACKSTAB_DAMAGE)
	
func cast_ultimate():
	pass
