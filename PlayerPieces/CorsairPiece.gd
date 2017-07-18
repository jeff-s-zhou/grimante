extends "PlayerPiece.gd"

const DEFAULT_SHOOT_DAMAGE = 3
const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_ARMOR_VALUE = 3
const UNIT_TYPE = "Corsair"

var moves_remaining = 2

var pathed_range

var shoot_damage = DEFAULT_SHOOT_DAMAGE setget , get_shoot_damage

const BULLET_PROTOTYPE = preload("res://PlayerPieces/Components/Bullet.tscn")

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.movement


func get_shoot_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SHOOT_DAMAGE

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	
func get_attack_range():
	return get_parent().get_range(self.coords, [1, 2], "ENEMY")
	
func get_hook_range():
	return get_parent().get_range(self.coords, [2, 8], "ENEMY", true)
	
func get_assist_hook_range():
	return get_parent().get_range(self.coords, [2, 8], "PLAYER", true)
	

func finisher_reactivate():
	self.moves_remaining = 2
	.finisher_reactivate()

func turn_update():
	self.moves_remaining = 2
	.turn_update()
	
func placed(ending_turn=false):
	self.moves_remaining -= 1
	if self.moves_remaining == 0 or ending_turn:
		.placed(ending_turn)
	else:
		self.handle_assist()
		get_parent().selected = null
		add_animation(self, "emit_animated_placed", false)

#neede for tutorials
func emit_animated_placed():
	emit_signal("animated_placed")
	

func get_shoot_coords(move_coords):
	#reverse the subtraction because we're getting the range in the opposite direction
	var line_range = self.grid.get_line_range(self.coords, self.coords - move_coords, "ENEMY")
	if line_range != []:
		return line_range[0]


func highlight_indirect_range(movement_range):
	for coords in movement_range:
		if get_shoot_coords(coords) != null:
			get_parent().locations[coords].indirect_highlight()
	

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var movement_range = get_movement_range()
	var action_range = get_attack_range() + movement_range + get_hook_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	highlight_indirect_range(movement_range)

func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_hook_range(new_coords):
	var hook_range = get_hook_range()
	return new_coords in hook_range
	
func _is_within_assist_hook_range(new_coords):
	var hook_range = get_assist_hook_range()
	return new_coords in hook_range
	
func _is_within_movement_range(new_coords):
	var movement_range = get_movement_range()
	return new_coords in movement_range


func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		move_shoot(new_coords)
		set_coords(new_coords)
		placed()
	elif _is_within_hook_range(new_coords):
		handle_pre_assisted()
		hook(new_coords)
		placed()
	elif _is_within_assist_hook_range(new_coords):
		handle_pre_assisted()
		hook(new_coords)
		placed()
	else:
		invalid_move()


func move_shoot(move_coords):
	var damage = self.shoot_damage
	
	#reverse the subtraction because we're getting the range in the opposite direction
	var attack_coords = get_shoot_coords(move_coords)
	if attack_coords != null:
		var action = get_new_action()
		
		#okay. the bullet HAS to be blocking so the damage is handled at the right time
		var args = [move_coords, 500, false]
		add_animation(self, "animate_move_and_hop", false, args)
		add_animation(self, "animate_shoot", true, [attack_coords])
		action.add_call("attacked", [self.shoot_damage], attack_coords)
		action.execute()
	else: #if just moving, block other shit from happening
		var args = [move_coords, 500, true]
		add_animation(self, "animate_move_and_hop", true, args)

func animate_shoot(attack_coords):
	var bullet = BULLET_PROTOTYPE.instance()
	get_parent().add_child(bullet)
	var final_pos = get_parent().locations[attack_coords].get_pos()
	var distance = (final_pos - get_pos()).length()
	var speed = 2200
	
	var angle = get_pos().angle_to_point(final_pos)
	bullet.set_rot(angle)
	
	get_node("Tween 2").interpolate_property(bullet, "transform/pos", get_pos(), final_pos, distance/speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	emit_signal("animation_done")
	bullet.queue_free()
	
func animate_extend_hook(start_coords, end_coords):
	add_anim_count()
	var new_pos = get_parent().locations[end_coords].get_pos()
	var current_pos = get_parent().locations[start_coords].get_pos()
	var angle = get_pos().angle_to_point(new_pos)
	
	var distance_length = (new_pos - current_pos).length()
	get_node("CorsairHook").animate_extend(distance_length, angle)
	yield(get_node("CorsairHook"), "animation_done")
	get_node("Timer").set_wait_time(0.1)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	subtract_anim_count()
	
func animate_retract_hook():
	add_anim_count()
	
	get_node("CorsairHook").animate_retract(630)
	yield(get_node("CorsairHook"), "animation_done")
	emit_signal("animation_done")
	subtract_anim_count()
	
func hook(new_coords):
	add_animation(self, "animate_extend_hook", true, [self.coords, new_coords])
	
	var armor_or_hp
	var target = get_parent().pieces[new_coords]
	if target.side == "PLAYER":
		armor_or_hp = target.armor
	elif target.side == "ENEMY":
		armor_or_hp = target.hp
		
	if armor_or_hp > self.armor:
		var adjacent_coords = new_coords - get_parent().hex_normalize(new_coords - self.coords)
		hooked(adjacent_coords)
		print("hooking")
		print(new_coords)
		add_animation(self, "animate_retract_hook", true)
	else:
		var adjacent_coords = self.coords + get_parent().hex_normalize(new_coords - self.coords)
		get_parent().pieces[new_coords].hooked(adjacent_coords)
		add_animation(self, "animate_retract_hook", true)


func predict(new_coords):
	if _is_within_movement_range(new_coords):
		predict_shoot(new_coords)

		
func predict_shoot(move_coords):
	var damage = self.shoot_damage
	var attack_coords = get_shoot_coords(move_coords)
	if attack_coords != null:
		var action = get_new_action()
		get_parent().pieces[attack_coords].predict(self.shoot_damage, true)

func cast_ultimate():
	pass
