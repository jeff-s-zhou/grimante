
extends "PlayerPiece.gd"

const UNIT_TYPE = "Stormdancer"

const DEFAULT_SHURIKEN_DAMAGE = 1
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_ARMOR_VALUE = 2

var shuriken_damage = DEFAULT_SHURIKEN_DAMAGE setget , get_shuriken_damage

const shuriken_prototype = preload("res://PlayerPieces/Components/Shuriken.tscn")

var rain_coords_dict = {}

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.defense


	
func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
	self.AssistSystem.activate_assist(self.assist_type, self)
	

func get_shuriken_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SHURIKEN_DAMAGE


func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	

func get_ally_swap_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value], "PLAYER")
	
	
func get_enemy_swap_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range() + get_enemy_swap_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	for coords in get_ally_swap_range():
		get_parent().get_at_location(coords).assist_highlight()



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
		placed()
		
	elif _is_within_movement_range(new_coords):
		handle_pre_assisted()
		add_animation(self, "animate_shunpo", true, [new_coords])
		get_parent().locations[self.coords].set_rain(true)
		self.rain_coords_dict[self.coords] = true
		set_coords(new_coords)
		shuriken_storm(new_coords)
		placed()
	else:
		invalid_move()

func shuriken_storm(new_coords):
	var attack_range_dict = {}
	var attack_range = get_parent().get_diagonal_range(new_coords, [1, 8], "ENEMY", true)
	for coords in attack_range:
		if get_parent().locations[coords].raining:
			attack_range_dict[coords] = true
		else:
			attack_range_dict[coords] = false
	if attack_range.size() > 0:
		add_animation(self, "animate_spin", false)
		throw_shurikens(attack_range, attack_range_dict)
	
	
func animate_spin():
	get_node("Physicals/SpinningForm").show()
	get_node("Physicals/AnimatedSprite").hide()
	animate_jump()
	var max_i = 18
	for i in range(0, max_i):
		var speed = 0
		var multiplier = quadratic(i, max_i)
		if multiplier == 0:
			speed = 0.2
		else:
			speed = 0.2/multiplier
		animate_spin_helper(speed)
		yield(get_node("Tween 2"), "tween_complete")
	
	get_node("Physicals/AnimatedSprite").show()
	get_node("Physicals/SpinningForm").hide()
	
func animate_jump():
	var timer = Timer.new()
	add_child(timer)
	var physicals = get_node("Physicals")
	var start_pos = physicals.get_pos()
	var end_pos = physicals.get_pos() + Vector2(0, -85)
	timer.set_wait_time(0.2)
	timer.start()
	yield(timer, "timeout")
	get_node("Tween 3").interpolate_property(physicals, "transform/pos", start_pos, end_pos, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween 3").start()
	yield(get_node("Tween 3"), "tween_complete")
	
	timer.set_wait_time(0.4)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	get_node("Tween 3").interpolate_property(physicals, "transform/pos", end_pos, start_pos, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween 3").start()
	
func animate_spin_helper(speed):
	var top = get_node("Physicals/SpinningForm/Top")
	var bottom = get_node("Physicals/SpinningForm/Bottom")
	var shadow = get_node("Shadow")
	var start_angle = top.get_rotd()
	var stop_angle = top.get_rotd() - 60
	get_node("Tween 2").interpolate_property(bottom, "frame", 0, 6, speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_property(top, "transform/rot", start_angle, stop_angle, speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_property(shadow, "transform/rot", start_angle, stop_angle, speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	get_node("Tween").start()
	yield(get_node("Tween 2"), "tween_complete")

func quadratic(i, max_range):
	var factor = 1.0/max_range
	var x_squared = pow(i, 2.0)
	return (-1.0 * (1.0/max_range) * pow(i, 2.0)) + i
	
func throw_shurikens(attack_range, attack_range_dict):
	#attack_range.invert()
	var delay = 0.25
	for coords in attack_range:
		#if true, that means enemy is on a lightning tile
		if attack_range_dict[coords]:
			var tile = get_parent().locations[coords]
			add_animation(tile, "animate_lightning", false)
		add_animation(self, "animate_shuriken_helper", true, [coords, delay])
		get_parent().pieces[coords].attacked(self.shuriken_damage)
		delay -= (delay/1.5)

func animate_shuriken_helper(attack_coords, delay):
	var shuriken = self.shuriken_prototype.instance()
	add_child(shuriken)
	var global_position = get_parent().locations[attack_coords].get_global_pos()
	shuriken.animate_attack(global_position, 900, delay)
	yield(shuriken, "animation_done")
	emit_signal("animation_done")

func tango(new_coords):
	add_animation(self, "animate_shunpo", true, [new_coords])
	var target = self.grid.pieces[new_coords]
	get_parent().locations[self.coords].set_rain(true)
	self.rain_coords_dict[self.coords] = true
	swap_coords_and_pos(target)
	
func animate_shunpo(new_coords):
	add_anim_count()
	get_node("AnimationPlayer 2").play("ShunpoOut")
	yield(get_node("AnimationPlayer 2"), "finished")
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	get_node("AnimationPlayer 2").play("ShunpoIn")
	yield(get_node("AnimationPlayer 2"), "finished")
	emit_signal("animation_done")
	subtract_anim_count()


func predict(new_coords):
	pass
