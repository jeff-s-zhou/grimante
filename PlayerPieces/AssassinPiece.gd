
extends "PlayerPiece.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default
const REGULAR_BACKSTAB_DAMAGE = 1
const ULTIMATE_BACKSTAB_DAMAGE = 2
const PASSIVE_DAMAGE = 1
const UNIT_TYPE = "Assassin"
const DESCRIPTION = """
"""
const BEHIND = Vector2(0, -1)

var backstab_damage = REGULAR_BACKSTAB_DAMAGE
var passive_damage = PASSIVE_DAMAGE

var pathed_range

func get_movement_range():
	self.pathed_range = get_parent().get_pathed_range(self.coords, 1)
	return self.pathed_range.keys()
	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, 3], "ENEMY")
	var attack_range = []
	for coords in unfiltered_range:
		if !get_parent().pieces.has(coords + BEHIND): #only return enemies with their backs open
			attack_range.append(coords)
			
	return attack_range
	
func get_passive_range():
	return get_parent().get_radial_range(self.coords, [1, 2], "ENEMY")


func animate_backstab(new_coords):
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
	
func _is_within_passive_range(new_coords):
	return new_coords in get_passive_range()


func act(new_coords):
	if _is_within_movement_range(new_coords):
		var args = [self.coords, new_coords, self.pathed_range, 350]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		get_node("/root/Combat").handle_archer_ultimate(new_coords)
		attack(new_coords)
	else:
		invalid_move()


func attack(new_coords):
	animate_backstab(new_coords + BEHIND)
	#TODO: yield to AnimationQueue call
	if get_parent().pieces[new_coords].will_die_to(self.backstab_damage):
		set_charge(get_charge() + 1)
	elif self.ultimate_flag:
		self.ultimate_flag = false #if it doesn't kill the piece, the ultimate is done
	get_parent().pieces[new_coords].attacked(self.backstab_damage)
	set_coords(new_coords + BEHIND)
	if !self.ultimate_flag:
		placed()
	else:
		get_parent().selected = null
		
func get_charge():
	return get_node("ChargeBar").charge

func set_charge(charge):
	get_node("ChargeBar").set_charge(charge)

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		get_parent().pieces[new_coords].predict(self.backstab_damage)

func cast_ultimate():
	if get_charge() == 3:
		self.ultimate_flag = true
		self.backstab_damage = ULTIMATE_BACKSTAB_DAMAGE
		get_parent().reset_highlighting()
		display_action_range()
		set_charge(0)
	
func placed():
	self.backstab_damage = REGULAR_BACKSTAB_DAMAGE
	.placed()
	
func trigger_passive(attack_coords):
	if _is_within_passive_range(attack_coords):
		get_node("/root/AnimationQueue").enqueue(self, "animate_passive", true, [attack_coords])
		get_parent().pieces[attack_coords].attacked(PASSIVE_DAMAGE)
		get_node("/root/AnimationQueue").enqueue(self, "animate_passive_end", true, [self.coords])

func animate_passive(attack_coords):
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 50, true, Tween.TRANS_SINE, Tween.EASE_IN)

func animate_passive_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)