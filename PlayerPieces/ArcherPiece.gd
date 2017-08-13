
extends "PlayerPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const DEFAULT_SHOOT_DAMAGE = 3
const DEFAULT_PASSIVE_DAMAGE = 3
const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_SHIELD = false

var shoot_damage = DEFAULT_SHOOT_DAMAGE setget , get_shoot_damage
var passive_damage = DEFAULT_PASSIVE_DAMAGE setget , get_passive_damage

var velocity
var new_position

var pathed_range

signal animation_finished

const UNIT_TYPE = "Archer"


func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(UNIT_TYPE)
	self.assist_type = ASSIST_TYPES.movement

func displays_line():
	return true
	
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
		

func highlight_indirect_range(movement_range):
	for coords in movement_range:
		if get_step_shot_coords(coords) != null:
			get_parent().locations[coords].indirect_highlight()


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var movement_range = get_movement_range()
	var action_range = get_attack_range() + movement_range
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	highlight_indirect_range(movement_range)


func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()

func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()


func act(new_coords):
	
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [new_coords, 350, false]
		add_animation(self, "animate_move_and_hop", false, args)
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

		
func piercing_arrow(new_coords):
	var damage = self.shoot_damage
	var line_range = self.grid.get_line_range(self.coords, new_coords - self.coords, "ENEMY")
	var final_hit_coords
	var action = get_new_action()
	for coords in line_range:
		final_hit_coords = coords
		
		var new_damage = damage
		action.add_call("attacked", [new_damage], coords)
		if self.grid.pieces[coords].will_die_to(damage) and damage > 0:
			damage -= 1
		else:
			break
			
	if final_hit_coords != null:
		add_animation(self, "animate_ranged_attack", true, [final_hit_coords])
	action.execute()


func animate_ranged_attack(new_coords):
	add_anim_count()
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var start_pos = get_parent().locations[self.coords].get_pos()
	var angle = start_pos.angle_to_point(new_position)
	
	var arrow = get_node("ArcherArrow")
	arrow.set_rot(angle)
	var distance = get_pos().distance_to(new_position)
	var speed = 2200
	var time = distance/speed
	
	get_node("Tween 2").interpolate_property(arrow, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_SINE, Tween.EASE_IN)
	
	var offset = Vector2(0, -10)
	var new_arrow_pos = (location.get_pos() - start_pos) + offset
	
	#draw back
	get_node("SamplePlayer 2").play("bow_draw")
	var draw_back_position = arrow.get_pos() - (40 * (new_arrow_pos - arrow.get_pos()).normalized())
	get_node("Tween 2").interpolate_property(arrow, "transform/pos", arrow.get_pos(), draw_back_position, 1.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
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
			predict_ranged_attack(new_coords, attack_coords, true)

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		predict_ranged_attack(self.coords, new_coords)


func predict_ranged_attack(position_coords, new_coords, is_passive=false):
	var damage = self.shoot_damage
	var line_range = self.grid.get_line_range(position_coords, new_coords - position_coords, "ENEMY")
	var final_hit_coords
	for coords in line_range:
		final_hit_coords = coords
		
		var new_damage = damage
		get_parent().pieces[coords].predict(new_damage, is_passive)
		if self.grid.pieces[coords].will_die_to(damage) and damage > 0:
			damage -= 1
		else:
			break