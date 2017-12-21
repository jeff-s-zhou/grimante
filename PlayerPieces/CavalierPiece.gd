
extends "PlayerPiece.gd"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const DEFAULT_TRAMPLE_DAMAGE = 2
const DEFAULT_CHARGE_DAMAGE = 3
const DEFAULT_MOVEMENT_VALUE = 8
const DEFAULT_SHIELD = true

var trample_damage = DEFAULT_TRAMPLE_DAMAGE setget , get_trample_damage

const UNIT_TYPE = "Cavalier"

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(UNIT_TYPE)
	self.assist_type = ASSIST_TYPES.movement
	
func get_trample_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_TRAMPLE_DAMAGE

#not a true getter function like the rest
func get_charge_damage(distance_travelled):
	return get_assist_bonus_attack() + DEFAULT_CHARGE_DAMAGE + self.attack_bonus + distance_travelled

func animate_hop(old_coords, new_coords, down=false, enemy=null):
	add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	var old_location = get_parent().locations[old_coords]
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = old_location.get_pos().distance_to(new_position)
	var time = distance/400
	var old_position = Vector2(0, -20)
	if down:
		old_position = Vector2(0, -5)
	var new_position = Vector2(0, -45)
	
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	if(down):
		set_z(0)
		self.mid_leaping_animation = false
	
	if enemy != null:
		enemy.animate_hit()
	emit_signal("animation_done")
	subtract_anim_count()

	
func play_hit_sound():
	get_node("SamplePlayer2D").play("hit")


func get_movement_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1]) #locations only
	
func get_attack_range():
	var attack_range = []
	var movement_range = get_movement_range()
	
	var enemy_range = get_parent().get_range(self.coords, [1, self.movement_value + 1], "ENEMY", true)
	for enemy_coords in enemy_range:
		var decremented_coords = decrement_one(enemy_coords)
		#allow it to point blank impale adjacent enemies
		if decremented_coords in movement_range or decremented_coords == self.coords:
			attack_range.append(enemy_coords)
			
	return attack_range
	
func highlight_indirect_range():
	var grid = get_parent()
	var indirect_range = []
	for i in range(0, 6):
		var increment = grid.get_change_vector(i)
		var trample_flag = false
		for j in range(0, 7):
			var coords = self.coords + (increment * j)
			if !grid.locations.has(coords):
				break
			#if an enemy is spotted, all tiles past it will cause trampling
			if grid.pieces.has(coords) and grid.pieces[coords].is_enemy():
				trample_flag = true
			if !grid.pieces.has(coords) and trample_flag == true:
				grid.locations[coords].indirect_highlight()
			
	
#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range() + get_attack_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	highlight_indirect_range()


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
	else:
		invalid_move()


func trample(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	var current_coords = self.coords
	
	var was_hopping = false

	set_coords(new_coords)
	
	while current_coords != new_coords:
		current_coords = current_coords + increment
		if get_parent().pieces.has(current_coords) and get_parent().pieces[current_coords].side == "ENEMY":
			was_hopping = true
			add_animation(self, "animate_move", false, [current_coords, 400, false])
			var enemy = get_parent().pieces[current_coords]
			add_animation(self, "animate_hop", true, [current_coords - increment, current_coords, false, enemy])
			var action = get_new_action()
			action.add_call("attacked", [self.trample_damage, self, 0], current_coords)
			action.execute()
		else:
			if was_hopping:
				#hop down
				add_animation(self, "animate_move", false, [current_coords, 400, false])
				add_animation(self, "animate_hop", true, [current_coords - increment, current_coords, true])
				was_hopping = false
			else:
				add_animation(self, "animate_move", false, [current_coords, 400, false])
				add_animation(self, "animate_hop", true, [current_coords - increment, current_coords, true])
	placed()


func decrement_one(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	return new_coords - increment


func charge_attack(new_coords, attack=false):
	var difference = new_coords - self.coords
	
	var unit_distance = get_parent().hex_normalize(new_coords - self.coords)
	var unit_pos_distance = get_parent().get_real_distance(unit_distance)
	var back_up_pos = self.get_pos() - unit_pos_distance/5
	var arguments = [back_up_pos, 100, true, Tween.TRANS_QUAD, Tween.EASE_OUT]
	add_animation(self, "animate_move_to_pos", true, arguments)
	
	add_animation(self, "animate_charge", true, [new_coords])
	var attack_range = [new_coords]
	var position_coords = decrement_one(new_coords)
	set_coords(position_coords)
	var tiles_travelled = get_parent().hex_length(difference) - 1
	var action = get_new_action()
	action.add_call("attacked", [get_charge_damage(tiles_travelled), self], attack_range)
	action.execute()
	
	var location = get_parent().locations[position_coords]
	var new_position = location.get_pos()
	add_animation(self, "animate_move_to_pos", true, [new_position, 300, true, Tween.TRANS_SINE, Tween.EASE_IN])
	placed()

	
func animate_charge(attack_coords):
	var location = get_parent().locations[attack_coords]
	var decremented_coords = decrement_one(attack_coords)
	var difference = 4 * (location.get_pos() - get_parent().locations[decremented_coords].get_pos())/5
	var new_position = location.get_pos() - difference
	
	animate_move_to_pos(new_position, 1000, true, Tween.TRANS_SINE, Tween.EASE_IN, 0.3)
	yield(self, "animation_done")
	emit_signal("shake")
	

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
			get_parent().pieces[current_coords].predict(self.trample_damage, self, true)


func predict_charge_attack(new_coords):
	var difference = new_coords - self.coords
	var tiles_travelled = get_parent().hex_length(difference) - 1
	get_parent().pieces[new_coords].predict(get_charge_damage(tiles_travelled), self)
	
	
func cast_ultimate():
	get_node("Physicals/OverlayLayers/UltimateWhite").show()
	self.ultimate_flag = true
	pass
