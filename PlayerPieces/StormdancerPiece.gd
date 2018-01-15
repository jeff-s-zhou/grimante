
extends "PlayerPiece.gd"

const UNIT_TYPE = "Stormdancer"

const DEFAULT_SHURIKEN_DAMAGE = 2
const LIGHTNING_BONUS_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_SHIELD = false

var shuriken_damage = DEFAULT_SHURIKEN_DAMAGE setget , get_shuriken_damage

const shuriken_prototype = preload("res://PlayerPieces/Components/Shuriken.tscn")

var rain_coords_dict = {}

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.movement
	self.diagonal_guide_prediction_flag = true


func get_shuriken_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SHURIKEN_DAMAGE


func get_movement_range():
	return self.grid.get_radial_range(self.coords, [1, self.movement_value])
	

func get_ally_swap_range():
	return self.grid.get_radial_range(self.coords, [1, self.movement_value], "PLAYER")
	
	
func get_enemy_swap_range():
	return self.grid.get_radial_range(self.coords, [1, self.movement_value], "ENEMY")

func get_shuriken_damage_range(damage_coords):
	return self.grid.get_diagonal_range(damage_coords, [1, 6], "ENEMY", true)

func highlight_indirect_range(movement_range):
	for coords in movement_range:
		var damage_range = get_shuriken_damage_range(coords)
		if damage_range != []:
			self.grid.locations[coords].indirect_highlight()


#parameters to use for get_node("self.grid").get_neighbors
func display_action_range():
	var action_range = get_movement_range() + get_enemy_swap_range()
	for coords in action_range:
		self.grid.get_at_location(coords).movement_highlight()
	for coords in get_ally_swap_range():
		self.grid.get_at_location(coords).assist_highlight()
	
	highlight_indirect_range(action_range)



func _is_within_movement_range(new_coords):
	var movement_range = get_movement_range()
	return new_coords in movement_range
	
func _is_within_swap_range(new_coords):
	var swap_range = get_ally_swap_range() + get_enemy_swap_range()
	return new_coords in swap_range


func act(new_coords):
	#returns whether the act was successfully committed
	if _is_within_swap_range(new_coords):
		handle_pre_assisted()
		tango(new_coords)
		shuriken_storm(new_coords)
		attack_placed()
		
	elif _is_within_movement_range(new_coords):
		handle_pre_assisted()
		add_animation(self, "animate_shunpo", true, [new_coords])
		self.grid.locations[self.coords].set_rain(true)
		self.rain_coords_dict[self.coords] = true
		set_coords(new_coords)
		shuriken_storm(new_coords)
		attack_placed()
	else:
		invalid_move()
		
#used so we can call the placed animation at the end of the spin
func attack_placed():
	self.grid.handle_field_of_lights(self)
	handle_assist()
	get_node("SelectedGlow").hide()
	self.state = States.PLACED
	self.attack_bonus = 0
	self.movement_value = self.DEFAULT_MOVEMENT_VALUE
	self.grid.selected = null
	
#need to always unglow because of the spinning shit
func deselect(acting=false):
	self.state = States.DEFAULT
	add_animation(self, "animate_unglow", false)
	get_node("SelectedGlow").hide()

func shuriken_storm(new_coords):
	var attack_range_dict = {}
	var attack_range = self.grid.get_diagonal_range(new_coords, [1, 8], "ENEMY", true)
	for coords in attack_range:
		if self.grid.locations[coords].raining:
			attack_range_dict[coords] = true
		else:
			attack_range_dict[coords] = false
	if attack_range.size() > 0:
		add_animation(self, "animate_spin", true)
		throw_shurikens(attack_range, attack_range_dict)
	else:
		add_animation(self, "animate_placed", false)
	
	
func animate_spin():
	get_node("Physicals/SpinningForm").show()
	get_node("Physicals/AnimatedSprite").hide()
	darken(0.3)
	animate_jump()
	var max_i = 18
	for i in range(0, max_i):
		if i == 7: #halfway point ish
			emit_signal("animation_done")
		var speed = 0
		var multiplier = quadratic(i, max_i)
		if multiplier == 0:
			speed = 0.15
		else:
			speed = 0.15/multiplier
		animate_spin_helper(speed)
		yield(get_node("Tween 2"), "tween_complete")
	lighten(0.2)
	get_node("Physicals/AnimatedSprite").show()
	get_node("Physicals/SpinningForm").hide()
	animate_placed()
	

	
func animate_jump():
	var timer = Timer.new()
	add_child(timer)
	var physicals = get_node("Physicals")
	var start_pos = physicals.get_pos()
	var end_pos = physicals.get_pos() + Vector2(0, -85)
#	timer.set_wait_time(0.1)
#	timer.start()
#	yield(timer, "timeout")
	set_z(get_z() + 3)
	get_node("Tween 3").interpolate_property(physicals, "transform/pos", start_pos, end_pos, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween 3").start()
	yield(get_node("Tween 3"), "tween_complete")
	
	timer.set_wait_time(0.4)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	get_node("Tween 3").interpolate_property(physicals, "transform/pos", end_pos, start_pos, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween 3").start()
	yield(get_node("Tween 3"), "tween_complete")
	set_z(get_z() - 3)
	
func animate_spin_helper(time):
	var top = get_node("Physicals/SpinningForm/Top")
	var bottom = get_node("Physicals/SpinningForm/Bottom")
	var shadow = get_node("Shadow")
	var start_angle = top.get_rotd()
	var stop_angle = top.get_rotd() - 60
	get_node("Tween 2").interpolate_property(bottom, "frame", 0, 6, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_property(top, "transform/rot", start_angle, stop_angle, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_property(shadow, "transform/rot", start_angle, stop_angle, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	get_node("Tween").start()
	yield(get_node("Tween 2"), "tween_complete")

func quadratic(i, max_range):
	var factor = 1.0/max_range
	var x_squared = pow(i, 2.0)
	return (-1.0 * (1.0/max_range) * pow(i, 2.0)) + i
	
func throw_shurikens(attack_range, attack_range_dict):
	#attack_range.invert()
	add_animation(self, "animate_throw_shurikens", true, [attack_range])
	var action = get_new_action()
	action.add_call("attacked", [self.shuriken_damage, self], attack_range)
	action.execute()

#throw them all at the same time, block for one
func animate_throw_shurikens(attack_range):
	var shuriken = self.shuriken_prototype.instance()
	add_child(shuriken)
	var first = true
	for attack_coords in attack_range:
		if first:
			first = false
		else:
			shuriken = self.shuriken_prototype.instance()
			add_child(shuriken)
		var global_position = self.grid.locations[attack_coords].get_global_pos()
		shuriken.animate_attack(global_position, 1200)
	yield(shuriken, "animation_done")
	emit_signal("animation_done")
	
func tango(new_coords):
	add_animation(self, "animate_shunpo", true, [new_coords])
	var target = self.grid.pieces[new_coords]
	self.grid.locations[self.coords].set_rain(true)
	self.rain_coords_dict[self.coords] = true
	swap_coords_and_pos(target)
	
	if target.unit_name.to_lower() != "saint": #if swapping with saint, should only trigger field of lights once
		self.grid.handle_field_of_lights(self)
	self.grid.handle_field_of_lights(target)
	
func animate_shunpo(new_coords):
	add_anim_count()
	get_node("AnimationPlayer 2").play("ShunpoOut")
	yield(get_node("AnimationPlayer 2"), "finished")
	var location = self.grid.locations[new_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	get_node("AnimationPlayer 2").play("ShunpoIn")
	yield(get_node("AnimationPlayer 2"), "finished")
	emit_signal("animation_done")
	subtract_anim_count()


func predict(new_coords):
	if !(_is_within_movement_range(new_coords) or _is_within_swap_range(new_coords)):
		return
		
#	#will swap
	var do_not_call_list 
	if self.grid.has_enemy(new_coords):
		var shuriken_range = self.grid.get_diagonal_range(self.coords, [1, 2], "ENEMY", true)
		if new_coords in shuriken_range:
			self.grid.pieces[new_coords].predict(shuriken_damage, self, true)
			
			#get all the aditional coords in the opposite direction, add them to a do not call list
			#then subtract all of those from the attack range below
			var direction_vector = self.coords - new_coords #opposite direction
			do_not_call_list = self.grid.get_line_range(self.coords, direction_vector, "ENEMY", [1, 5])
			
	elif self.grid.has_ally(new_coords):
		var direction_vector = self.coords - new_coords #opposite direction
		do_not_call_list = self.grid.get_line_range(self.coords, direction_vector, "ENEMY", [1, 5])

	#no swapping
	var attack_range = get_shuriken_damage_range(new_coords)
	if do_not_call_list != null:
		for coords in do_not_call_list:
			attack_range.erase(coords)
	
	for coords in attack_range:
		self.grid.pieces[coords].predict(self.shuriken_damage, self, true)
