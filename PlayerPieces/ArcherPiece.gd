
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

const DESCRIPTION = """Armor: 0
Movement: 1 range step
Attack: Snipe. Attack the first enemy in a line for 4 damage. Can target diagonally. """
	
func get_attack_range():
	var attack_range = get_parent().get_range(self.coords, [1, 11], "ENEMY", true)
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
		placed()

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		ranged_attack(new_coords)
		yield(self, "animation_finished")
		placed()
		
	else:
		invalid_move()

	
	
func ranged_attack(new_coords):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var angle = get_pos().angle_to_point(new_position)
	
	var arrow = get_node("ArcherArrow")
	arrow.set_rot(angle)
	var distance = get_pos().distance_to(new_position)
	var speed = 400
	var time = distance/speed
	
	get_node("Tween").interpolate_property(arrow, "visibility/opacity", 0, 1, 0.6, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	var offset = Vector2(0, -10)
	var new_arrow_pos = (location.get_pos() - get_pos()) + offset
	get_node("Tween").interpolate_property(arrow, "transform/pos", arrow.get_pos(), new_arrow_pos, time, Tween.TRANS_BACK, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	arrow.set_opacity(0)
	arrow.set_pos(offset)
	get_parent().pieces[new_coords].attacked(4)
	emit_signal("animation_finished")

#override so that when pushed, it dies
func push(distance, is_knight=false):
	if(is_knight):
		.push(distance)
	else:
		delete_self()
