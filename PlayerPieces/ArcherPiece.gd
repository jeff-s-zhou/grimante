
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

Inspire: +1 Range
"""
const ATTACK_DESCRIPTION = """Snipe. Fire an arrow at the first enemy in a line for 3 damage. Can target diagonally. Allies will block the shot.
"""
const PASSIVE_DESCRIPTION = """ Running Fire. Whenever you move, attempt to Snipe down the column of your new position (failing if an ally is in the way).

"""


func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.movement
	

	
func get_shoot_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SHOOT_DAMAGE
	
func get_passive_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_PASSIVE_DAMAGE
	

func get_attack_range():
	var attack_range = get_parent().get_range(self.coords, [1, 11], "ENEMY", true)
	var attack_range_diagonal = get_parent().get_diagonal_range(self.coords, [1, 8], "ENEMY", true)
	return attack_range + attack_range_diagonal

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	
func get_step_shot_coords(coords):
	var step_shot_range = get_parent().get_range(coords, [1, 11], "ENEMY", true, [0, 1])
	if step_shot_range.size() > 0:
		return step_shot_range[0]
	else:
		return null


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	
	.display_action_range()
		
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()

func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()


func act(new_coords):
	
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [new_coords, 350, true]
		get_node("/root/AnimationQueue").enqueue(self, "animate_move_and_hop", true, args)
		set_coords(new_coords)
		var coords = get_step_shot_coords(self.coords)
		if coords != null:
			#get_node("/root/Combat").display_overlay(self.unit_name)
			piercing_arrow(coords)
		placed()

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		#get_node("/root/Combat").display_overlay(self.unit_name)
		piercing_arrow(new_coords)
		placed()
	else:
		invalid_move()

func ranged_attack(new_coords, damage):
	get_node("/root/AnimationQueue").enqueue(self, "animate_ranged_attack", true, [new_coords])
	var action = get_new_action(new_coords)
	action.add_call("attacked", [damage])
	action.execute()
		
		
func piercing_arrow(new_coords):
	var actions = []
	var damage = self.shoot_damage
	var line_range = self.grid.get_line_range(self.coords, new_coords - self.coords, "ENEMY")
	var final_hit_coords
	print("in piercing arrow")
	print(line_range)
	for coords in line_range:
		final_hit_coords = coords
		var action = get_new_action(coords)
		var new_damage = damage
		action.add_call("attacked", [new_damage])
		actions.append(action)
		if self.grid.pieces[coords].hp <= damage and damage > 0:
			damage -= 1
		else:
			print("breaking here")
			break
			
	if final_hit_coords != null:
		get_node("/root/AnimationQueue").enqueue(self, "animate_ranged_attack", true, [final_hit_coords])
	for action in actions:
		action.execute()
	placed()


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
	get_node("SamplePlayer 2").play("bow_draw")
	var draw_back_position = arrow.get_pos() - (40 * (new_arrow_pos - arrow.get_pos()).normalized())
	get_node("Tween 2").interpolate_property(arrow, "transform/pos", arrow.get_pos(), draw_back_position, 1.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	get_node("Tween 2").interpolate_property(arrow, "transform/pos", arrow.get_pos(), new_arrow_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	print("time to fire arrow is " + str(time))
	
	#get_node("Tween 2").interpolate_callback(self, max(time - 0.1, 0), "play_bow_hit")
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	get_node("SamplePlayer 2").play("bow_hit")
	arrow.set_opacity(0)
	arrow.set_pos(offset)
	
	emit_signal("animation_done")
	subtract_anim_count()

func play_bow_hit():
	get_node("SamplePlayer 2").play("bow_hit")

func predict(new_coords):
	if _is_within_movement_range(new_coords):
		var attack_coords = get_step_shot_coords(new_coords)
		if attack_coords != null:
			predict_passive_ranged_attack(new_coords, attack_coords)

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		predict_ranged_attack(new_coords)


func predict_passive_ranged_attack(new_position_coords, new_attack_coords):
	get_parent().pieces[new_attack_coords].predict(self.passive_damage, true)


func predict_ranged_attack(new_coords):
	get_parent().pieces[new_coords].predict(self.shoot_damage, false)


	