extends "PlayerPiece.gd"

const DEFAULT_SHOOT_DAMAGE = 2
const DEFAULT_SLASH_DAMAGE = 3
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_SHIELD = true
const UNIT_TYPE = "Corsair"

var moves_remaining = 2

var pathed_range

var shoot_damage = DEFAULT_SHOOT_DAMAGE setget , get_shoot_damage
var slash_damage = DEFAULT_SLASH_DAMAGE setget , get_slash_damage

const BULLET_PROTOTYPE = preload("res://PlayerPieces/Components/Bullet.tscn")

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.movement


func get_shoot_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SHOOT_DAMAGE
	
func get_slash_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SLASH_DAMAGE

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	
func get_melee_range():
	return get_parent().get_radial_range(self.coords, [1, 1], "ENEMY")

func get_pull_range():
	var full_range = get_parent().get_range(self.coords, [1, 8], "ANY", true)
	#janky ass way to have the full collision check, but only return [2,8]
	if full_range != [] and full_range[0] in get_parent().get_location_range(self.coords, [1, 2]):
		full_range.pop_front()
	return full_range
	
func get_hookshot_range():
	var target_range = get_parent().get_range(self.coords, [3, 8], "ANY", true)
	#get the coords of the tile right before
	var tile_range = []
	for coords in target_range:
		var unit_distance = get_parent().hex_normalize(coords - self.coords)
		tile_range.append(coords - unit_distance)
	return tile_range

func star_reactivate():
	self.moves_remaining = 2
	.star_reactivate()

func turn_update():
	self.moves_remaining = 2
	.turn_update()
	
func placed(ending_turn=false):
	self.moves_remaining -= 1
	if self.moves_remaining == 0 or ending_turn:
		.placed(ending_turn)
	else:
		self.handle_assist()
		self.grid.handle_field_of_lights(self)
		add_animation(self, "animate_half_placed", false)
		check_for_traps()

func resurrect(coords):
	self.moves_remaing = 2
	.resurrect(coords)

func animate_resurrect(blocking=true):
	get_node("Physicals/AnimatedSprite/HalfCooldownSprite").hide()
	get_node("Physicals/AnimatedSprite").set_self_opacity(1)
	.animate_resurrect(blocking)

func animate_reactivate(star_reactivate=false):
	get_node("Physicals/AnimatedSprite/HalfCooldownSprite").hide()
	get_node("Physicals/AnimatedSprite").set_self_opacity(1)
	.animate_reactivate(star_reactivate)
	
		
func animate_half_placed():
	print("animating half placed")
	get_node("AnimationPlayer").stop() #stop the glow animation
	animate_unglow()
	get_node("Physicals/AnimatedSprite/HalfCooldownSprite").show()
	var sprite = get_node("Physicals/AnimatedSprite")
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(sprite, "visibility/self_opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete")
	print("opacity: ", get_node("Physicals/GlowSprite").get_opacity())
	tween.queue_free()


#have to do this manually because for prediction, we need to specifically ignore the corsair's piece
func get_shoot_coords(new_coords, old_coords):
	var increment = self.grid.hex_normalize(old_coords - new_coords) #going in the opposite direction
	var current_coords = old_coords
	#return first unit in this direction that is an enemy, ignoring the corsair
	for i in range(0, 8):
		current_coords += increment
		if self.grid.locations.has(current_coords):
			if self.grid.pieces.has(current_coords):
				var piece = self.grid.pieces[current_coords]
				if piece.side == "ENEMY":
					return piece.coords
				elif piece != self:
					break
	return null

func get_en_garde_coords(new_coords):
	if self.grid.has_enemy(new_coords + Vector2(0, -1)):
		return new_coords + Vector2(0, -1)

func highlight_indirect_range(movement_range):
	for move_coords in movement_range:
		if get_shoot_coords(move_coords, self.coords) != null:
			get_parent().locations[move_coords].indirect_highlight()
		elif get_en_garde_coords(move_coords) != null:
			get_parent().locations[move_coords].indirect_highlight()
	

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var movement_range = get_movement_range()
	var action_range = movement_range + get_melee_range() # get_hookshot_range() + get_pull_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	highlight_indirect_range(movement_range)
	
	
func _is_within_movement_range(new_coords):
	var movement_range = get_movement_range()
	return new_coords in movement_range
	
func _is_within_hookshot_range(new_coords):
	return new_coords in get_hookshot_range()
	
func _is_within_pull_range(new_coords):
	return new_coords in get_pull_range()
	
func _is_within_melee_range(new_coords):
	return new_coords in get_melee_range()

#we have en_garde delayed scaling to how far the corsair lept
#this is because we only have the bullet blocking in move_shoot so that the enemy animation can play in time
#but the leap takes more time, but we need the en_garde to wait for the leap to finish lol
func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var shoot_leap_length = move_shoot(new_coords)
		en_garde(new_coords, shoot_leap_length)
		placed()
	elif _is_within_melee_range(new_coords):
		handle_pre_assisted()
		slash(new_coords)
		placed()
	else:
		invalid_move()

	
func en_garde(new_coords, shoot_leap_length):
	var attack_coords = new_coords + Vector2(0, -1)
	if self.grid.has_enemy(attack_coords):
		if shoot_leap_length != null:
			var delay = shoot_leap_length * 0.18
			slash(attack_coords, delay)
		else:
			slash(attack_coords)

		
func slash(new_coords, delay=0.0):
	get_node("/root/AnimationQueue").enqueue(self, "animate_draw_back", true, [new_coords, delay])
	get_node("/root/AnimationQueue").enqueue(self, "animate_slash", true, [new_coords])
	var action = get_new_action()
	action.add_call("attacked", [self.slash_damage, self], new_coords)
	action.execute()
	get_node("/root/AnimationQueue").enqueue(self, "animate_slash_end", true, [self.coords])


func animate_draw_back(new_coords, delay=0.0):
	if delay > 0.0:
		get_node("Timer").set_wait_time(delay)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
	var unit_distance = get_parent().hex_normalize(new_coords - self.coords)
	var unit_pos_distance = get_parent().get_real_distance(unit_distance)
	var back_up_pos = self.get_pos() - unit_pos_distance/5
	animate_move_to_pos(back_up_pos, 200, true, Tween.TRANS_QUAD, Tween.EASE_OUT)


func animate_slash(attack_coords):
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(0.2)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 1200, true, Tween.TRANS_LINEAR, Tween.EASE_IN)

func animate_slash_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 1000, true)


func move_shoot(move_coords):
	#reverse the subtraction because we're getting the range in the opposite direction
	var old_coords = self.coords
	set_coords(move_coords)
	var attack_coords = get_shoot_coords(self.coords, old_coords)
	
	if attack_coords != null:
		var action = get_new_action()
		
		#okay. the bullet HAS to be blocking so the damage is handled at the right time
		var args = [move_coords, 450, false]
		add_animation(self, "animate_move_and_hop", false, args)
		add_animation(self, "animate_shoot", true, [attack_coords])
		
		action.add_call("attacked", [self.shoot_damage, self], attack_coords)
		action.execute()
		return self.grid.hex_length(move_coords - old_coords)
	else: #if just moving, block other shit from happening
		var args = [move_coords, 450, true]
		add_animation(self, "animate_move_and_hop", true, args)
		return null

func animate_shoot(attack_coords):
	#get_node("/root/Combat").darken(0.1, 0.2)
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(0.1)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	
	var bullet = BULLET_PROTOTYPE.instance()
	self.grid.add_child(bullet)
	bullet.set_global_pos(get_node("Physicals").get_global_pos())
	var final_pos = get_parent().locations[attack_coords].get_pos() + (Vector2(0, -7)) #height of the piece
	var distance = (final_pos - get_pos()).length()
	var speed = 2200
	
	var angle = get_pos().angle_to_point(final_pos)
	bullet.set_rot(angle)
	bullet.set_opacity(1)
	get_node("Tween 2").interpolate_property(bullet, "transform/pos", bullet.get_pos(), final_pos, distance/speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	
	yield(get_node("Tween 2"), "tween_complete")
	emit_signal("animation_done")
	bullet.queue_free()


func predict(new_coords):
	if _is_within_movement_range(new_coords):
		predict_shoot(new_coords)
		predict_en_garde(new_coords)
		
	elif _is_within_melee_range(new_coords):
		predict_melee(new_coords)
		
func predict_melee(attack_coords):
	get_parent().pieces[attack_coords].predict(self.slash_damage, self)
	
	
func predict_en_garde(move_coords):
	var attack_coords = move_coords + Vector2(0, -1)
	if self.grid.has_enemy(attack_coords):
		get_parent().pieces[attack_coords].predict(self.slash_damage, self, true)

		
func predict_shoot(move_coords):
	var damage = self.shoot_damage
	var attack_coords = get_shoot_coords(move_coords, self.coords)
	if attack_coords != null:
		var action = get_new_action()
		get_parent().pieces[attack_coords].predict(self.shoot_damage, self, true)

func cast_ultimate():
	pass
