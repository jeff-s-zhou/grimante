
extends "PlayerPiece.gd"
#extends KinematicBody2D
# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/cavalier_piece.png"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

signal cavalier_animation_finished

const UNIT_TYPE = "Cavalier"
const DESCRIPTION = """Armor: 1
Movement: Can move to any empty tile along a straight line.
Passive: Trample. Moving through an enemy unit deals 2 damage to it.
Attack: Charge. Run in a straight line, hitting the first enemy in the line for damage equal to the number of tiles travelled.
"""

func animate_attack(attack_coords):
	self.mid_animation = true
	print("animating attack")
	var location = get_parent().locations[attack_coords]
	var decremented_coords = decrement_one(attack_coords)
	
	var difference = (location.get_pos() - get_parent().locations[decremented_coords].get_pos())/2
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, Tween.TRANS_SINE, Tween.EASE_IN)
	
func play_hit_sound():
	get_node("SamplePlayer2D").play("hit")
	
func animate_attack_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300)


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
		var decremented_coords = decrement_one(new_coords)
		charge_move(decremented_coords, true)
		
	elif _is_within_movement_range(new_coords):
		charge_move(new_coords)
	else:
		invalid_move()
	
func decrement_one(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	return new_coords - increment


func charge_move(new_coords, attack=false):
	set_z(2)
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	if(attack):
		animate_attack(new_coords + increment)
		
	else:
		animate_move(new_coords, 350)
	yield(get_node("Tween"), "tween_complete")
	set_z(-1)

	var current_coords = self.coords + increment
	
	var tiles_passed = 1
	#deal damage to every tile you passed over
	while(current_coords != new_coords):
		if get_parent().pieces.has(current_coords) and get_parent().pieces[current_coords].side == "ENEMY":
			get_parent().pieces[current_coords].attacked(2)
			
		tiles_passed += 1
		current_coords = current_coords + increment


	if attack:
		charge_attack(new_coords, new_coords + increment, tiles_passed)
	else:
		print("set coords for cavalier")
		print(new_coords)
		set_coords(new_coords)
		placed()



func charge_attack(position_coords, attack_coords, tiles_passed):
	get_parent().pieces[attack_coords].attacked(tiles_passed)
	animate_attack_end(position_coords)
	print("set coords for cavalier")
	print(position_coords)
	set_coords(position_coords)
	placed()


