
extends "PlayerPiece.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default
const BACKSTAB_DAMAGE = 1
const UNIT_TYPE = "Assassin"
const DESCRIPTION = """
"""
const BEHIND = Vector2(0, -1)

var kill_streak = 0

func get_movement_range():
	return get_parent().get_range(self.coords)
	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, 3], "ENEMY")
	var attack_range = []
	for coords in unfiltered_range:
		if !get_parent().pieces.has(coords + BEHIND): #only return enemies with their backs open
			attack_range.append(coords)
			
	return attack_range

	
func animate_backstab(new_coords):
	self.mid_animation = true
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	set_pos(new_position)

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
	if _is_within_movement_range(new_coords):
		animate_move(new_coords, 350)
		yield(get_node("Tween"), "tween_complete")
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		var false_or_yield = get_node("/root/Combat").handle_archer_ultimate(new_coords)
		if (false_or_yield):
			yield(get_node("/root/Combat"), "archer_ultimate_handled")
		attack(new_coords)
	else:
		invalid_move()


func attack(new_coords):
	animate_backstab(new_coords + BEHIND)
	#yield(get_node("AnimationPlayer"), "finished")
	if get_parent().pieces[new_coords].will_die_to(BACKSTAB_DAMAGE):
		self.kill_streak += 1
	get_parent().pieces[new_coords].attacked(BACKSTAB_DAMAGE)
	set_coords(new_coords + BEHIND)
	placed()

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		get_parent().pieces[new_coords].predict(BACKSTAB_DAMAGE)

func cast_ultimate():
	pass
