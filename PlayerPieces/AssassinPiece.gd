
extends "PlayerPiece.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default
const BACKSTAB_DAMAGE = 2
const PASSIVE_DAMAGE = 1
const UNIT_TYPE = "Assassin"
const DESCRIPTION = """
"""
const BEHIND = Vector2(0, -1)

var backstab_damage = BACKSTAB_DAMAGE
var passive_damage = PASSIVE_DAMAGE

var pathed_range

func _ready():
	self.armor = 0

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


func animate_backstab(attack_coords):
	var position_coords = attack_coords + BEHIND

	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("AssassinFade"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	yield(get_node("Tween 2"), "tween_complete")
	var location = get_parent().locations[position_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	
	var attack_location = get_parent().locations[attack_coords]
	var difference = 2 * (attack_location.get_pos() - get_pos())/3
	var attack_position = attack_location.get_pos() - difference
	
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("AssassinFade"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)


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
		backstab(new_coords)
	else:
		invalid_move()


func backstab(new_coords):
	get_node("/root/AnimationQueue").enqueue(self, "animate_backstab", true, [new_coords])
	#TODO: yield to AnimationQueue call
	get_parent().pieces[new_coords].attacked(self.backstab_damage)
	var return_position = get_parent().locations[new_coords + BEHIND].get_pos()
	get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [return_position, 200, true])
	set_coords(new_coords + BEHIND)
	if self.ultimate_flag:
		if get_parent().pieces.has(new_coords): #if it didn't kill
			soft_placed() 

	else:
		if !get_parent().pieces.has(new_coords): #if it did kill
			set_charge(get_charge() + 1)
		placed()


func get_charge():
	return get_node("ChargeBar").charge

func set_charge(charge):
	get_node("ChargeBar").set_charge(charge)

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		get_parent().pieces[new_coords].predict(self.backstab_damage)

func cast_ultimate():
#	if get_charge() == 3:
	self.ultimate_flag = true
	get_parent().reset_highlighting()
	display_action_range()
	set_charge(0)
	
func placed():
	.placed()
	
#same as regular placed() except doesn't reset the ultimate_flag
func soft_placed(): 
	get_node("/root/AnimationQueue").enqueue(self, "animate_placed", false)
	self.state = States.PLACED
	get_parent().selected = null


#resets the assassin to be able to act again
func unplaced():
	self.state = States.DEFAULT
	get_node("AnimatedSprite").play("default")


func trigger_passive(attack_coords):
	if _is_within_passive_range(attack_coords):
		get_node("/root/AnimationQueue").enqueue(self, "animate_passive", true, [attack_coords])
		get_parent().pieces[attack_coords].attacked(PASSIVE_DAMAGE)
		if self.ultimate_flag:
			unplaced()
		get_node("/root/AnimationQueue").enqueue(self, "animate_passive_end", true, [self.coords])


func animate_passive(attack_coords):
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, true, Tween.TRANS_SINE, Tween.EASE_IN)

func animate_passive_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)