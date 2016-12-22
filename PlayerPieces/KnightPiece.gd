
extends "PlayerPiece.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Knight"
const DESCRIPTION = """Armor: 2
Movement: 1 range step
Attack: Shove. 1 range, pushes target back and also pushes targets behind them. Can push friendly units and not KO them.
"""
	
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
		shove(new_coords)
	else:
		invalid_move()


func shove(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	animate_move(new_coords)
	get_parent().pieces[new_coords].push(increment, true)
	yield(get_node("Tween"), "tween_complete")
	set_coords(new_coords)
	placed()
	
func cast_ultimate():
	pass
