
extends "PlayerPiece.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Knight"
const DESCRIPTION = """Armor: 2
Movement: Rush - Can move to any empty tile along a straight line path.\n
Attack: Joust. Targeting an enemy unit at the end of your Rush deals 1 damage for every tile travelled. Applies Knockback.\n
Passive: Trample. Moving through an enemy unit deals 1 damage to it."""
	
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
		animate_move(new_coords, 150)
		yield(get_node("Tween"), "tween_complete")
		set_coords(new_coords)
		animate_placed()
		return true
	elif _is_within_shove_range(new_coords):
		shove(new_coords)
		return true

	return false


func shove(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	animate_move(new_coords)
	get_parent().pieces[new_coords].push(increment)
	yield(get_node("Tween"), "tween_complete")
	set_coords(new_coords)
	animate_placed()
	

