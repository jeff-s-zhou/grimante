
extends "PlayerPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/archer_piece.png"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

var velocity
var new_position

signal animation_finished

const UNIT_TYPE = "Archer"

const DESCRIPTION = ""
	
func get_attack_range():
	var attack_range = get_parent().get_range(self.coords, [2, 11], "ENEMY", true)
	var attack_range_diagonal = get_parent().get_diagonal_range(self.coords, [1, 8], "ENEMY", true)
	return attack_range + attack_range_diagonal

func get_movement_range():
	return get_parent().get_range(self.coords)


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
		
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()

func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()


func act(new_coords):
	#if the tile selected is within movement range
	if _is_within_movement_range(new_coords):
		animate_move(new_coords)
		yield(get_node("Tween"), "tween_complete")
		set_coords(new_coords)
		animate_placed()
		return true

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		ranged_attack(new_coords)
		animate_placed()
		return true

	return false

	
	
func ranged_attack(new_coords):
	get_parent().pieces[new_coords].attacked(4)
