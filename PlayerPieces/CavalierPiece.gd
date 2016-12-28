
extends "PlayerPiece.gd"
#extends KinematicBody2D
# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/cavalier_piece.png"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

signal cavalier_animation_finished

const TRAMPLE_DAMAGE = 2

const UNIT_TYPE = "Cavalier"
const DESCRIPTION = """Armor: 1
Movement: Can move to any empty tile along a straight line.
Passive: Trample. Moving through an enemy unit deals 2 damage to it.
Attack: Charge. Run in a straight line, hitting the first enemy in the line for damage equal to the number of tiles travelled.
"""

func animate_attack(attack_coords):
	print("animating attack")
	var location = get_parent().locations[attack_coords]
	var decremented_coords = decrement_one(attack_coords)
	
	var difference = 2 * (location.get_pos() - get_parent().locations[decremented_coords].get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 500, true, Tween.TRANS_SINE, Tween.EASE_IN)
	yield(get_node("Tween"), "tween_complete")
	emit_signal("shake")

	
func play_hit_sound():
	get_node("SamplePlayer2D").play("hit")


func animate_attack_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)


func get_movement_range():
	return get_parent().get_range(self.coords, [1, 11]) #locations only
	
func get_attack_range():
	var attack_range = []
	var movement_range = get_movement_range()
	
	var enemy_range = get_parent().get_range(self.coords, [1, 11], "ENEMY", true)
	for enemy_coords in enemy_range:
		var decremented_coords = decrement_one(enemy_coords)
		if decremented_coords in movement_range:
			attack_range.append(enemy_coords)
			
	return attack_range

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range() + get_attack_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()


func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range


func _is_within_movement_range(new_coords):
	var movement_range = get_movement_range()
	return new_coords in movement_range


func act(new_coords):
	#returns whether the act was successfully committed
	
	if _is_within_attack_range(new_coords):
		get_node("/root/Combat").handle_archer_ultimate(new_coords)
		charge_attack(new_coords)
		get_node("/root/Combat").handle_assassin_passive(new_coords)
		
	elif _is_within_movement_range(new_coords):
		trample(new_coords)
	else:
		invalid_move()


func trample(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	var current_coords = self.coords
	
	var was_hopping = false
	while current_coords != new_coords:
		current_coords = current_coords + increment
		if get_parent().pieces.has(current_coords) and get_parent().pieces[current_coords].side == "ENEMY":
			was_hopping = true
			get_parent().pieces[current_coords].attacked(TRAMPLE_DAMAGE)
			get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [current_coords, 250, false])
			get_node("/root/AnimationQueue").enqueue(self, "animate_hop", true, [current_coords - increment, current_coords])
			
		else:
			if was_hopping:
				#hop down
				get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [current_coords, 250, false])
				get_node("/root/AnimationQueue").enqueue(self, "animate_hop", true, [current_coords - increment, current_coords, true])
				was_hopping = false
			else:
				get_node("/root/AnimationQueue").enqueue(self, "animate_move", true, [current_coords, 350])

	set_coords(new_coords)
	placed()


func animate_hop(old_coords, new_coords, down=false):
	set_z(2)
	var old_location = get_parent().locations[old_coords]
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = old_location.get_pos().distance_to(new_position)
	var time = distance/250
	print(time)
	var old_position = Vector2(0, -15)
	if down:
		old_position = Vector2(0, -4)
	var new_position = Vector2(0, -60)
	
	get_node("Tween2").interpolate_property(get_node("AnimatedSprite"), "transform/pos", \
		get_node("AnimatedSprite").get_pos(), new_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	
	get_node("Tween2").interpolate_property(get_node("AnimatedSprite"), "transform/pos", \
		get_node("AnimatedSprite").get_pos(), old_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	if(down):
		set_z(-1)
	emit_signal("animation_done")


func decrement_one(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	return new_coords - increment


func charge_attack(new_coords, attack=false):
	var difference = new_coords - self.coords
	var tiles_travelled = get_parent().hex_length(difference) - 1
	get_node("/root/AnimationQueue").enqueue(self, "animate_attack", true, [new_coords])
	get_parent().pieces[new_coords].attacked(tiles_travelled)
	var position_coords = decrement_one(new_coords)
	get_node("/root/AnimationQueue").enqueue(self, "animate_attack_end", true, [position_coords])
	set_coords(position_coords)
	placed()
	

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		var decremented_coords = decrement_one(new_coords)
		predict_charge_move(decremented_coords, true)
		
	elif _is_within_movement_range(new_coords):
		predict_charge_move(new_coords)


func predict_charge_move(new_coords, attack=false):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	var current_coords = self.coords + increment
	
	var tiles_passed = 1
	#deal damage to every tile you passed over
	while(current_coords != new_coords):
		if get_parent().pieces.has(current_coords) and get_parent().pieces[current_coords].side == "ENEMY":
			get_parent().pieces[current_coords].predict(TRAMPLE_DAMAGE, true)
		tiles_passed += 1
		current_coords = current_coords + increment

	if attack:
		get_parent().pieces[new_coords + increment].predict(tiles_passed)

func cast_ultimate():
	pass