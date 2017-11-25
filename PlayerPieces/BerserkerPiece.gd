
extends "PlayerPiece.gd"
#extends KinematicBody2D
const DEFAULT_DAMAGE = 4
const DEFAULT_AOE_DAMAGE = 2
const DEFAULT_SHIELD = false
const DEFAULT_MOVEMENT_VALUE = 2

var damage = DEFAULT_DAMAGE setget , get_damage
var aoe_damage = DEFAULT_AOE_DAMAGE setget , get_aoe_damage


const ANIMATION_STATES = {"default":0, "moving":1, "jumping":2}

var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Berserker"

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.assist_type = ASSIST_TYPES.attack
	load_description(UNIT_TYPE)
	
func get_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_DAMAGE
	
func get_aoe_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_AOE_DAMAGE

func get_attack_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")
	
func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	
func highlight_indirect_range(movement_range):
	#print("highlighting indirect range berserker")
	var indirect_range = []
	var enemies = get_tree().get_nodes_in_group("enemy_pieces")
	for enemy in enemies:
		var adjacent_range = get_parent().get_radial_range(enemy.coords, [1, 1])
		for coords in adjacent_range:
			if coords in movement_range:
				get_parent().locations[coords].indirect_highlight()

#parameters to use for get_node("Grid").get_neighbors
func display_action_range():
	var movement_range = get_movement_range()
	var action_range = get_attack_range() + movement_range
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	highlight_indirect_range(movement_range)


func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	
func jump_to(new_coords, dust=false):
	add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	
	var speed = 350
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var dim_distance = dim_multi_distance(distance)
	var time = dim_distance/speed
	time = max(0.30, time) #if short hop looks weird, switch this back to 0.35

	var old_height = get_node("Physicals").get_pos()
	var vertical = min(-3.0 * distance/4, -90)
	var new_height = Vector2(0, vertical)

	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_height, time/2.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_height, time/2.0, Tween.TRANS_QUART, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	var cracks = get_node("Cracks")
	var slam_ring = get_node("SlamRing")
	var explosion = get_node("SlamExplosion")
	if dust:
		cracks.set_opacity(1)
		#explosion.set_opacity(1)
		explosion.set_enabled(true)
		slam_ring.set_scale(Vector2(0.3, 0.3))
		slam_ring.set_opacity(1)
		get_parent().get_node("FieldEffects").emit_dust(self.get_pos())
		var tween = Tween.new()
		add_child(tween)
		
		tween.interpolate_property(slam_ring, "visibility/opacity", \
		1, 0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN, 0.2)
		tween.interpolate_property(slam_ring, "transform/scale", \
		Vector2(0.3, 0.3), Vector2(1.6, 1.6), 0.7, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
	self.mid_leaping_animation = false
	set_z(0)
	get_node("SamplePlayer 2").play("explode3")
	emit_signal("shake")
	emit_signal("animation_done")
	subtract_anim_count()
	
	if dust:
		#yield(get_node("Tween 2"), "tween_complete")
		get_node("Tween 2").interpolate_property(cracks, "visibility/opacity", \
		1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.3)
#		get_node("Tween 2").interpolate_property(explosion, "visibility/opacity", \
#		1, 0, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN, 0.3)
		get_node("Tween 2").interpolate_property(explosion, "energy", \
		4, 0.01, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.3)
		get_node("Tween 2").start()
		
		yield(get_node("Tween 2"), "tween_complete")
		yield(get_node("Tween 2"), "tween_complete")
		explosion.set_enabled(false)
	
func jump_back(new_coords):
	add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	
	var speed = 300
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var dim_distance = dim_multi_distance(distance)
	var time = dim_distance/speed
	time = max(0.30, time) #if short hop looks weird, switch this back to 0.35

	var old_height = get_node("Physicals").get_pos()
	var vertical = min(-1 * distance/2, -60)
	var new_height = Vector2(0, vertical)

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
	add_animation(self, "animate_move", false, [new_coords, 350, false])
	add_animation(self, "jump_to", true, [new_coords])
	var action = get_new_action()
	
	var lethal = get_parent().pieces[new_coords].will_die_to(damage, self)
	
	action.add_call("attacked", [self.damage, self], new_coords)
	action.execute()
	if lethal:
		set_coords(new_coords)
		placed()
	#else leap back
	else:
		add_animation(self, "animate_move", false, [self.coords, 300, false])
		add_animation(self, "jump_back", true, [self.coords])
		placed()



func smash_move(new_coords):
	add_animation(self, "animate_move", false, [new_coords, 350, false])
	add_animation(self, "jump_to", true, [new_coords, true])
	
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	#add_animation(self, "animate_smash", false, [new_coords])
	smash(smash_range)
	set_coords(new_coords)
	placed()


func smash(smash_range):
	var action = get_new_action()
	action.add_call("set_stunned", [true, 0.2], smash_range)
	#the false flag is so it doesn't interrupt the stun it just set lol
	action.add_call("attacked", [self.aoe_damage, self, 0.2], smash_range)
	action.execute()
	
	
func animate_smash(coords):
	var smash_range = self.grid.get_range(coords)
	var smash_pieces = []
	var smash_tiles = []
	
	for coords in smash_range:
		if self.grid.pieces.has(coords):
			self.smash_pieces.append(self.grid.pieces[coords])
		smash_tiles.append(self.grid.locations[coords])
	
	var smash_targets = smash_pieces + smash_tiles
	
	for target in smash_targets:
		sub_animate_smash(target)
		
func sub_animate_smash(target):
	var height = Vector2(0, -60)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(target, "transform/pos", \
		target.get_pos(), target.get_pos() + height, 0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_complete")
	tween.interpolate_property(target, "transform/pos", \
		target.get_pos(), target.get_pos() - height, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()
	yield(tween, "tween_complete")
	tween.queue_free()

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		predict_smash_attack(new_coords)
	elif _is_within_movement_range(new_coords):
		predict_smash_move(new_coords)


func predict_smash_attack(new_coords):
	get_parent().pieces[new_coords].predict(self.damage, self)
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")


func predict_smash_move(new_coords):
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	for coords in smash_range:
		get_parent().pieces[coords].predict(self.aoe_damage, self, true)


func cast_ultimate():
	get_node("Physicals/OverlayLayers/UltimateWhite").show()
	self.ultimate_flag = true
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.attack_bonus += 1
		player_piece.movement_value += 1
	get_parent().reset_highlighting()
	display_action_range()
	

