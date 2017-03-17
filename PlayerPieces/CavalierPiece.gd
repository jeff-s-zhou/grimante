
extends "PlayerPiece.gd"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const DEFAULT_TRAMPLE_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 11
const DEFAULT_ARMOR_VALUE = 5

var trample_damage = DEFAULT_TRAMPLE_DAMAGE setget , get_trample_damage


const UNIT_TYPE = "Cavalier"
const OVERVIEW_DESCRIPTION = """Armored.

Movement: Able to move to any empty tile along a straight line.
"""

const PASSIVE_DESCRIPTION = """Trample. Moving through an enemy unit deals 2 damage to it.
"""

const ATTACK_DESCRIPTION = """Charge. Run in a straight line, hitting the first enemy in the line for damage equal to the number of tiles travelled.
"""

const ULTIMATE_DESCRIPTION = """Rally! For the rest of this Player Phase, all allied units have +1 movement and deal +1 damage.
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
	
func get_trample_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_TRAMPLE_DAMAGE

#not a true getter function like the rest
func get_charge_damage(distance_travelled):
	return get_assist_bonus_attack() + self.attack_bonus + distance_travelled

func animate_attack(attack_coords):
	print("animating attack")
	var location = get_parent().locations[attack_coords]
	var decremented_coords = decrement_one(attack_coords)
	
	var difference = 2 * (location.get_pos() - get_parent().locations[decremented_coords].get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 500, true, Tween.TRANS_SINE, Tween.EASE_IN)
	yield(get_node("Tween"), "tween_complete")
	emit_signal("shake")
	

func animate_hop(old_coords, new_coords, down=false):
	self.mid_leaping_animation = true
	set_z(3)
	var old_location = get_parent().locations[old_coords]
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = old_location.get_pos().distance_to(new_position)
	var time = distance/250
	print(time)
	var old_position = Vector2(0, -15)
	if down:
		old_position = Vector2(0, 0)
	var new_position = Vector2(0, -60)
	
	get_node("Tween2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	
	get_node("Tween2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	if(down):
		set_z(0)
	self.mid_leaping_animation = false
	emit_signal("animation_done")

	
func play_hit_sound():
	get_node("SamplePlayer2D").play("hit")


func animate_attack_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)


func get_movement_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1]) #locations only
	
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
	.display_action_range()


func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range


func _is_within_movement_range(new_coords):
	var movement_range = get_movement_range()
	return new_coords in movement_range


func act(new_coords):
	#returns whether the act was successfully committed
	
	if _is_within_attack_range(new_coords):
		handle_pre_assisted()
		#get_node("/root/Combat").display_overlay(self.unit_name)
		charge_attack(new_coords)
		
	elif _is_within_movement_range(new_coords):
		handle_pre_assisted()
		trample(new_coords)
	elif _is_within_ally_shove_range(new_coords):
		handle_pre_assisted()
		initiate_friendly_shove(new_coords)
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
			get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [current_coords, 250, false])
			get_node("/root/AnimationQueue").enqueue(self, "animate_hop", true, [current_coords - increment, current_coords])
			var action = get_new_action(current_coords)
			action.add_call("attacked", [self.trample_damage])
			action.execute()
			
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


func decrement_one(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	return new_coords - increment


func charge_attack(new_coords, attack=false):
	var difference = new_coords - self.coords
	var tiles_travelled = get_parent().hex_length(difference) - 1
	get_node("/root/AnimationQueue").enqueue(self, "animate_attack", true, [new_coords])
	var increment = get_parent().hex_normalize(difference)
	
	var attack_range = [new_coords]
	if get_parent().pieces.has(new_coords + increment): #if there's an enemy directly behind this one
		if get_parent().pieces[new_coords + increment].side == "ENEMY":
			attack_range.append(new_coords + increment)
	var action = get_new_action(attack_range)
	action.add_call("attacked", [get_charge_damage(tiles_travelled)])
	action.execute()
	var position_coords = decrement_one(new_coords)
	get_node("/root/AnimationQueue").enqueue(self, "animate_attack_end", true, [position_coords])
	set_coords(position_coords)
	placed()
	

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		predict_charge_attack(new_coords)
		
	elif _is_within_movement_range(new_coords):
		predict_trample(new_coords)


func predict_trample(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	var current_coords = self.coords
	
	while current_coords != new_coords:
		current_coords = current_coords + increment
		if get_parent().pieces.has(current_coords) and get_parent().pieces[current_coords].side == "ENEMY":
			get_parent().pieces[current_coords].predict(self.trample_damage, true)


func predict_charge_attack(new_coords):
	var difference = new_coords - self.coords
	var tiles_travelled = get_parent().hex_length(difference) - 1
	get_parent().pieces[new_coords].predict(get_charge_damage(tiles_travelled))
	

func cast_ultimate():
	get_node("Physicals/OverlayLayers/UltimateWhite").show()
	self.ultimate_flag = true
	pass
		
func placed():
	if self.ultimate_flag:
		self.ultimate_used_flag = true
		self.ultimate_flag = false
	.placed()