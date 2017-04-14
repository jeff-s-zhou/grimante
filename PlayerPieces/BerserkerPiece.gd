
extends "PlayerPiece.gd"
#extends KinematicBody2D
const DEFAULT_DAMAGE = 4
const DEFAULT_AOE_DAMAGE = 2
const DEFAULT_ARMOR_VALUE = 4
const DEFAULT_MOVEMENT_VALUE = 2

var damage = DEFAULT_DAMAGE setget , get_damage
var aoe_damage = DEFAULT_AOE_DAMAGE setget , get_aoe_damage


const ANIMATION_STATES = {"default":0, "moving":1, "jumping":2}

var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Berserker"

const OVERVIEW_DESCRIPTION = """4 Armor

Movement: 2 Range Leap Move

Inspire: +1 Attack
"""

const ATTACK_DESCRIPTION = """ Leap Strike. Deal 4 damage to an enemy within movement range. If the enemy is killed by the attack, move to its tile.
"""
const PASSIVE_DESCRIPTION = """Earthshatter.  Moving to an empty tile deals 2 damage to all enemies adjacent to the tile and stuns them.
"""

const ULTIMATE_DESCRIPTION = """Earthshatter. Stun and attack all enemies in a line from the Berserker, damage starting at 5 and decreasing by 1 for each enemy hit.
"""


func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.attack
	
func get_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_DAMAGE
	
func get_aoe_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_AOE_DAMAGE

func get_attack_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")
	
func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])

#parameters to use for get_node("Grid").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()

func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	
func play_smash_sound():
	get_node("SamplePlayer").play("explode3")

func jump_to(new_coords, speed=4):
	add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	print(distance)
	var speed = 300
	var one_tile_travelled = 115
	var time = 100 * (distance/one_tile_travelled)/speed
	time = max(0.45, time)
#	time = (distance) / (speed) 
#	print(time)

	var old_height = Vector2(0, 0)
	#var new_height = Vector2(0, (-3 * distance/4))
	var vertical = min(-3.0 * distance/4, -100)
	var new_height = Vector2(0, vertical)
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_height, time/2.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_height, time/2.0, Tween.TRANS_QUART, Tween.EASE_IN)
	get_node("Tween").interpolate_callback(self, time/2 - 0.1, "play_smash_sound")
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	self.mid_leaping_animation = false
	set_z(0)
	emit_signal("shake")
	emit_signal("animation_done")
	subtract_anim_count()

	
func jump_back(new_coords):
	add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var speed = 300
	var time = distance/speed

	var old_height = Vector2(0, 0)
	var new_height = Vector2(0, (-1 * distance/2.0))
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_height, time/2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_height, time/2.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	self.mid_leaping_animation = false
	set_z(0)
	emit_signal("animation_done")
	subtract_anim_count()

func act(new_coords):
	if _is_within_attack_range(new_coords):
		handle_pre_assisted()
		#get_node("/root/Combat").display_overlay(self.unit_name)
		smash_attack(new_coords)
	elif _is_within_movement_range(new_coords):
		handle_pre_assisted()
		smash_move(new_coords)
	else:
		invalid_move()


func smash_attack(new_coords):
	get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [new_coords, 350, false])
	get_node("/root/AnimationQueue").enqueue(self, "jump_to", true, [new_coords])
	if get_parent().pieces[new_coords].will_die_to(self.damage):
		var action = get_new_action(new_coords)
		action.add_call("smash_killed", [self.damage])
		action.execute()
		set_coords(new_coords)
		placed()

	#else leap back
	else:
		var action = get_new_action(new_coords)
		action.add_call("attacked", [self.damage])
		action.execute()
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords, 300, false])
		get_node("/root/AnimationQueue").enqueue(self, "jump_back", true, [self.coords])
		placed()



func smash_move(new_coords):
	get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [new_coords, 350, false])
	get_node("/root/AnimationQueue").enqueue(self, "jump_to", true, [new_coords])
	
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	smash(smash_range)
	set_coords(new_coords)
	placed()


func smash(smash_range):
	#attack_event = new aoe_attack_event(smash_range)
	#attack_event.add_call(attacked, [self.aoe_damage, true])
	#attack_event.add_call(set_stunned, [true])
	#attack_event.execute()
	var action = get_new_action(smash_range)
	action.add_call("set_stunned", [true])
	action.add_call("attacked", [self.aoe_damage])
	action.execute()


func predict(new_coords):
	if _is_within_attack_range(new_coords):
		predict_smash_attack(new_coords)
	elif _is_within_movement_range(new_coords):
		predict_smash_move(new_coords)


func predict_smash_attack(new_coords):
	get_parent().pieces[new_coords].predict(self.damage)
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")


func predict_smash_move(new_coords):
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	for coords in smash_range:
		get_parent().pieces[coords].predict(self.aoe_damage, true)


func cast_ultimate():
	get_node("Physicals/OverlayLayers/UltimateWhite").show()
	self.ultimate_flag = true
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.attack_bonus += 1
		player_piece.movement_value += 1
	get_parent().reset_highlighting()
	display_action_range()
	

func placed():
	if self.ultimate_flag:
		self.ultimate_used_flag = true
		self.ultimate_flag = false
	.placed()


