
extends "PlayerPiece.gd"
#extends KinematicBody2D
const DEFAULT_DAMAGE = 3
const DEFAULT_AOE_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 2

var damage = DEFAULT_DAMAGE setget , get_damage
var aoe_damage = DEFAULT_AOE_DAMAGE setget , get_aoe_damage

const ANIMATION_STATES = {"default":0, "moving":1, "jumping":2}

var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Berserker"

const OVERVIEW_DESCRIPTION = """Armored.

Movement: 2 range leap
"""

const ATTACK_DESCRIPTION = """Leap Strike. Deal 3 damage to an enemy within movement range. If the enemy is killed by the attack, move to its tile.
"""
const PASSIVE_DESCRIPTION = """Ground Slam. Moving to a tile deals 2 damage to all units around your destination.
"""

const ULTIMATE_DESCRIPTION = """Earthshatter. Stun and attack all enemies in a line from the Berserker, damage starting at 5 and decreasing by 1 for each enemy hit.
"""


func _ready():
	self.armor = 1
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION
	
func get_damage():
	return self.attack_bonus + DEFAULT_DAMAGE
	
func get_aoe_damage():
	return self.attack_bonus + DEFAULT_AOE_DAMAGE


func get_attack_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value + 1], "ENEMY")
	
func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value + 1])

#parameters to use for get_node("Grid").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()


func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()

func play_smash_sound():
	get_node("SamplePlayer2D").play("explode3")

func jump_to(new_coords, speed=4):
	self.mid_leaping_animation = true
	set_z(3)
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var speed = 300
	var time = (2 * distance) / (speed  * distance/100 ) 
#	print(time)
#	time = (distance) / (speed) 
#	print(time)

	var old_height = Vector2(0, -4)
	var new_height = Vector2(0, (-3 * distance/4))
	get_node("Tween2").interpolate_property(get_node("AnimatedSprite"), "transform/pos", \
		get_node("AnimatedSprite").get_pos(), new_height, time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	get_node("Tween2").interpolate_property(get_node("AnimatedSprite"), "transform/pos", \
		get_node("AnimatedSprite").get_pos(), old_height, time/2, Tween.TRANS_QUART, Tween.EASE_IN)
	get_node("Tween").interpolate_callback(self, time/2 - 0.1, "play_smash_sound")
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	self.mid_leaping_animation = false
	set_z(0)
	emit_signal("shake")
	emit_signal("animation_done")

	
func jump_back(new_coords):
	self.mid_leaping_animation = true
	set_z(3)
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var speed = 300
	var time = distance/speed

	var old_height = Vector2(0, -4)
	var new_height = Vector2(0, (-1 * distance/2))
	get_node("Tween2").interpolate_property(get_node("AnimatedSprite"), "transform/pos", \
		get_node("AnimatedSprite").get_pos(), new_height, time/2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	get_node("Tween2").interpolate_property(get_node("AnimatedSprite"), "transform/pos", \
		get_node("AnimatedSprite").get_pos(), old_height, time/2, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	self.mid_leaping_animation = false
	set_z(0)
	emit_signal("animation_done")

#called when an event happens inside the click area hitput
func input_event(viewport, event, shape_idx):
	if event.is_action("select") and event.is_pressed():
		if get_parent().selected == null and self.state != States.PLACED:
			get_node("SamplePlayer").play("mouseover")
#			var sample = get_node("SamplePlayer").get_sample_library().get_sample("mouseover").get_rid()
#			AudioServer.voice_play(AudioServer.voice_create(), sample)
			get_parent().selected = self
			self.state = States.CLICKED
			get_node("BlueGlow").show()
			#hovered()
		else: #if not selected, then some piece is trying to act on this one
			get_parent().set_target(self)

func act(new_coords):
	if _is_within_attack_range(new_coords):
		get_node("/root/Combat").handle_archer_ultimate(new_coords)
		smash_attack(new_coords)
		get_node("/root/Combat").handle_assassin_passive(new_coords)
	elif _is_within_movement_range(new_coords):
		smash_move(new_coords)
	else:
		invalid_move()


func smash_attack(new_coords):
	if get_parent().pieces[new_coords].will_die_to(self.damage):
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [new_coords, 350, false])
		get_node("/root/AnimationQueue").enqueue(self, "jump_to", true, [new_coords])
		
		get_parent().pieces[new_coords].smash_killed(self.damage)
		var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
		smash(smash_range)
		set_coords(new_coords)
		placed()
		
	#else leap back
	else:
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [new_coords, 350, false])
		get_node("/root/AnimationQueue").enqueue(self, "jump_to", true, [new_coords])
		
		get_parent().pieces[new_coords].attacked(self.damage)
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
	for coords in smash_range:
		get_parent().pieces[coords].attacked(self.aoe_damage)


func predict(new_coords):
	if _is_within_attack_range(new_coords):
		predict_smash_attack(new_coords)
	elif _is_within_movement_range(new_coords):
		predict_smash_move(new_coords)


func predict_smash_attack(new_coords):
	if get_parent().pieces[new_coords].hp - self.damage <= 0:
		get_parent().pieces[new_coords].predict(self.damage)
		var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
		predict_smash(smash_range)
	else:
		get_parent().pieces[new_coords].predict(self.damage)

func predict_smash_move(new_coords):
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	predict_smash(smash_range)

func predict_smash(smash_range):
	for coords in smash_range:
		get_parent().pieces[coords].predict(self.aoe_damage, true)

func cast_ultimate():
	pass



