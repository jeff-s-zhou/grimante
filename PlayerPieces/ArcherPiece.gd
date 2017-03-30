
extends "PlayerPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const DEFAULT_SHOOT_DAMAGE = 3
const DEFAULT_PASSIVE_DAMAGE = 3
const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_ARMOR_VALUE = 2

var shoot_damage = DEFAULT_SHOOT_DAMAGE setget , get_shoot_damage
var passive_damage = DEFAULT_PASSIVE_DAMAGE setget , get_passive_damage

var velocity
var new_position

var pathed_range

signal animation_finished

const UNIT_TYPE = "Archer"

const OVERVIEW_DESCRIPTION = """2 Armor.

Movement: 1 Range Step Move

Inspire: +1 Move
"""
const ATTACK_DESCRIPTION = """Snipe. Fire an arrow at the first enemy in a line for 3 damage. Can target diagonally. Allies will block the shot.
"""
const PASSIVE_DESCRIPTION = """ Running Fire. Whenever you move, attempt to Snipe down the column of your new position (failing if an ally is in the way).

"""
const ULTIMATE_DESCRIPTION = """Gain +2 damage for this turn. The next Snipe, if it kills the target, continues travelling in the same direction, dealing 1 less damage for each target it kills and passes through.
"""


func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.movement
	

	
func get_shoot_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SHOOT_DAMAGE
	
func get_passive_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_PASSIVE_DAMAGE
	

func get_attack_range():
	var attack_range = get_parent().get_range(self.coords, [1, 11], "ENEMY", true)
	var attack_range_diagonal = get_parent().get_diagonal_range(self.coords, [1, 8], "ENEMY", true)
	return attack_range + attack_range_diagonal
	
func get_ultimate_range():
	var attack_range = get_parent().get_range(self.coords, [1, 11], "ENEMY")
	var attack_range_diagonal = get_parent().get_diagonal_range(self.coords, [1, 8], "ENEMY")
	return attack_range + attack_range_diagonal

func get_movement_range():
	self.pathed_range = get_parent().get_pathed_range(self.coords, self.movement_value)
	return self.pathed_range.keys()
	
func get_step_shot_coords(coords):
	var step_shot_range = get_parent().get_range(coords, [1, 11], "ENEMY", true, [0, 1])
	if step_shot_range.size() > 0:
		return step_shot_range[0]
	else:
		return null


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range
	if self.ultimate_flag:
		action_range = get_ultimate_range() + get_movement_range()
	else:
		action_range = get_attack_range() + get_movement_range()
		
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	
	.display_action_range()
		
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()

func _is_within_attack_range(new_coords):
	if self.ultimate_flag:
		return new_coords in get_ultimate_range()
	return new_coords in get_attack_range()


func act(new_coords):
	
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [self.coords, new_coords, self.pathed_range, 350]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		var coords = get_step_shot_coords(self.coords)
		if coords != null:
			#get_node("/root/Combat").display_overlay(self.unit_name)
			ranged_attack(coords, self.passive_damage)
		placed()

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		#get_node("/root/Combat").display_overlay(self.unit_name)
		ranged_attack(new_coords, self.shoot_damage)
		placed()
	else:
		invalid_move()

func ranged_attack(new_coords, damage):
	
	if self.ultimate_flag:
		silver_arrow(new_coords)
	else:
		get_node("/root/AnimationQueue").enqueue(self, "animate_ranged_attack", true, [new_coords])
		var action = get_new_action(new_coords)
		action.add_call("attacked", [damage])
		action.execute()


func silver_arrow(new_coords):
	var damage_range
	var direction = get_parent().get_direction_from_vector(new_coords - self.coords)
	if direction == null:
		direction = get_parent().get_diagonal_direction_from_vector(new_coords - self.coords)
		damage_range = get_parent().get_diagonal_range(self.coords, [1, 11], "ENEMY", false, [direction, direction +1])
	else:
		damage_range = get_parent().get_range(self.coords, [1, 11], "ENEMY", false, [direction, direction +1])
	
	var damage = self.shoot_damage
	
	var last_hit_coords = damage_range[-1] #by default set the last hit to the furthest enemy away in the line
	for coords in damage_range:
		if damage == 0:
			last_hit_coords = coords #if it stops prematurely, the arrow stops there
		damage -= 1
	#animate hitting to the last coords hit
	get_node("/root/AnimationQueue").enqueue(self, "animate_ranged_attack", true, [last_hit_coords])
	
	damage = self.shoot_damage

	for coords in damage_range:
		if damage == 0:
			break
		var action = get_new_action(coords)
		action.add_call("attacked", [damage])
		action.execute()
		damage -= 1
	placed()

func animate_ranged_attack(new_coords):
	add_anim_count()
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var angle = get_pos().angle_to_point(new_position)
	
	var arrow = get_node("ArcherArrow")
	arrow.set_rot(angle)
	var distance = get_pos().distance_to(new_position)
	var speed = 2200
	var time = distance/speed
	
	get_node("Tween 2").interpolate_property(arrow, "visibility/opacity", 0, 1, 0.6, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	var offset = Vector2(0, -10)
	var new_arrow_pos = (location.get_pos() - get_pos()) + offset
	
	#draw back
	#get_node("SamplePlayer").play("bow_draw")
	var draw_back_position = arrow.get_pos() - (40 * (new_arrow_pos - arrow.get_pos()).normalized())
	get_node("Tween 2").interpolate_property(arrow, "transform/pos", arrow.get_pos(), draw_back_position, 1.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	get_node("Tween 2").interpolate_property(arrow, "transform/pos", arrow.get_pos(), new_arrow_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	print("time to fire arrow is " + str(time))
	#get_node("Tween 2").interpolate_callback(self, max(time - 0.1, 0), "play_bow_hit")
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	arrow.set_opacity(0)
	arrow.set_pos(offset)
	
	emit_signal("animation_done")
	subtract_anim_count()

func play_bow_hit():
	get_node("SamplePlayer").play("bow_hit")

func predict(new_coords):
	if _is_within_movement_range(new_coords):
		var attack_coords = get_step_shot_coords(new_coords)
		if attack_coords != null:
			predict_passive_ranged_attack(new_coords, attack_coords)

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		predict_ranged_attack(new_coords)


func predict_passive_ranged_attack(new_position_coords, new_attack_coords):
	if self.ultimate_flag:
		predict_ultimate_attack(new_position_coords, new_attack_coords)
	else:
		get_parent().pieces[new_attack_coords].predict(self.passive_damage, true)


func predict_ranged_attack(new_coords):
	if self.ultimate_flag:
		predict_ultimate_attack(self.coords, new_coords)
	else:
		get_parent().pieces[new_coords].predict(self.shoot_damage, false)
	

func predict_ultimate_attack(position_coords, attack_coords):
	var damage_range
	var direction = get_parent().get_direction_from_vector(attack_coords - position_coords)
	if direction == null:
		direction = get_parent().get_diagonal_direction_from_vector(attack_coords  - position_coords)
		damage_range = get_parent().get_diagonal_range(self.coords, [1, 11], "ENEMY", false, [direction, direction +1])
	else:
		damage_range = get_parent().get_range(self.coords, [1, 11], "ENEMY", false, [direction, direction +1])

	var damage = self.shoot_damage
	for coords in damage_range:
		if damage == 0:
			break
		if coords == attack_coords:
			get_parent().pieces[coords].predict(damage)
		else:
			get_parent().pieces[coords].predict(damage, true)
		damage -= 1
#	
	
func cast_ultimate():
	get_node("Physicals/OverlayLayers/UltimateWhite").show()
	#first reset the highlighting on the parent nodes. Then call the new highlighting
	self.ultimate_flag = true
	self.attack_bonus += 2
	get_parent().reset_highlighting()
	display_action_range()


func placed():
	if self.ultimate_flag:
		self.ultimate_used_flag = true
		self.ultimate_flag = false
	.placed()

	
func display_overwatch():
	pass


	