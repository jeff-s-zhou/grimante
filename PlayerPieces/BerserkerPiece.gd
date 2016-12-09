
extends "PlayerPiece.gd"
#extends KinematicBody2D
const DAMAGE = 3
const AOE_DAMAGE = 2

const ANIMATION_STATES = {"default":0, "moving":1, "jumping":2}

var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Berserker"

const DESCRIPTION = """Armor: 1
Movement: 2 range leap
Attack: Leap Strike. Leap to a tile. If there is an enemy on the tile, deal 3 damage. If the enemy is killed by the attack, move to that tile. Otherwise, return to your original tile.
Passive: Ground Slam. Moving to a tile deals 2 damage in a 1-range AoE around your destination."""

signal movement_animation_finished

func get_attack_range():
	return get_parent().get_radial_range(self.coords, [1, 3], "ENEMY")
	
func get_movement_range():
	return get_parent().get_radial_range(self.coords)

#parameters to use for get_node("Grid").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()


func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()

func animate_smash():
	get_node("AnimationPlayer").play("smash")
	#get_node("Tween").interpolate_callback(self, 0.1, "play_smash_sound")
	yield( get_node("AnimationPlayer"), "finished" )
	emit_signal("shake")
	emit_signal("movement_animation_finished")

func play_smash_sound():
	get_node("SamplePlayer2D").play("explode3")

func jump_to(new_coords, speed=4):
	set_z(2)
	self.mid_animation = true
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var speed = 350
	var time = distance/speed
	
	get_node("AnimationPlayer").play("jump")

	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), new_position, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").interpolate_callback(self, time + 0.2, "animate_smash")
	get_node("Tween").start()
	yield( get_node("AnimationPlayer"), "finished" )
	
	get_node("AnimationPlayer").play("float")
	
func jump_back(new_coords):
	set_z(2)
	self.mid_animation = true
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var time = 0.8
	get_node("AnimationPlayer").play("jump_back")
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), new_position, time, Tween.TRANS_SINE, Tween.EASE_IN)
	
	

func act(new_coords):
	if _is_within_attack_range(new_coords):
		print("is within attack range")
		smash_attack(new_coords)
	elif _is_within_movement_range(new_coords):
		smash_move(new_coords)
	else:
		invalid_move()


func smash_attack(new_coords):
	if get_parent().pieces[new_coords].hp - DAMAGE <= 0:
		jump_to(new_coords)
		yield(self, "movement_animation_finished")
		get_parent().pieces[new_coords].smash_killed(DAMAGE)
		var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
		smash(smash_range)
		set_coords(new_coords)
		set_z(-1)
		placed()
		
	#else leap back
	else:
		jump_to(new_coords)
		yield(self, "movement_animation_finished")
		get_parent().pieces[new_coords].attacked(DAMAGE)
		jump_back(self.coords)
		yield( get_node("AnimationPlayer"), "finished" )
		set_z(-1)
		placed()


func smash_move(new_coords):
	jump_to(new_coords)
	yield(self, "movement_animation_finished")
	var smash_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	smash(smash_range)
	set_coords(new_coords)
	set_z(-1)
	placed()


func smash(smash_range):
	for coords in smash_range:
		get_parent().pieces[coords].attacked(AOE_DAMAGE)








