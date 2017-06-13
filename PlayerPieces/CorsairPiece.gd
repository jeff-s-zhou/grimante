extends "PlayerPiece.gd"

const DEFAULT_SLASH_DAMAGE = 3
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_ARMOR_VALUE = 4
const UNIT_TYPE = "Corsair"

var moves_remaining = 2

var pathed_range

var slash_damage = DEFAULT_SLASH_DAMAGE setget , get_slash_damage

const ATTACK_DESCRIPTION = """
"""

const PASSIVE_DESCRIPTION = """"""


func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.movement


func get_slash_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SLASH_DAMAGE

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	
func get_attack_range():
	return get_parent().get_range(self.coords, [1, 2], "ENEMY")
	
func get_hook_range():
	return get_parent().get_range(self.coords, [1, 3], "ENEMY", true)
	
func get_assist_hook_range():
	return get_parent().get_range(self.coords, [1, 3], "PLAYER", true)
	

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
	

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range() + get_hook_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()

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
		var args = [new_coords, 350, true]
		add_animation(self, "animate_move_and_hop", true, args)
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		add_animation(self, "animate_slash", true, [new_coords])
		slash(new_coords)
		add_animation(self, "animate_slash_end", true, [self.coords])
		placed()
	elif _is_within_hook_range(new_coords):
		handle_pre_assisted()
		add_animation(self, "animate_extend_hook", true, [new_coords])
		var adjacent_coords = hook(new_coords)
		add_animation(self, "animate_retract_hook", true, [new_coords])
		add_animation(self, "animate_slash", true, [adjacent_coords])
		slash(adjacent_coords)
		add_animation(self, "animate_slash_end", true, [self.coords])
		placed()
	elif _is_within_assist_hook_range(new_coords):
		handle_pre_assisted()
		add_animation(self, "animate_extend_hook", true, [new_coords])
		var adjacent_coords = hook(new_coords)
		add_animation(self, "animate_retract_hook", true, [new_coords])
		placed()
	else:
		invalid_move()


func slash(new_coords):
	var action = get_new_action()
	action.add_call("attacked", [self.slash_damage], new_coords)
	action.execute()

func animate_slash(attack_coords):
	var location = get_parent().locations[attack_coords]
	var difference = 4 * (location.get_pos() - get_pos())/5
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, true, Tween.TRANS_SINE, Tween.EASE_IN)

func animate_slash_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)
	
func animate_extend_hook(new_coords):
	add_anim_count()
	var new_pos = get_parent().locations[new_coords].get_pos()
	var current_pos = get_parent().locations[self.coords].get_pos()
	var angle = get_pos().angle_to_point(new_pos)
	
	var distance_length = (new_pos - current_pos).length()
	
	get_node("CorsairHook").animate_extend(distance_length, angle)
	yield(get_node("CorsairHook"), "animation_done")
	get_node("Timer").set_wait_time(0.1)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	subtract_anim_count()
	
func animate_retract_hook(new_coords):
	add_anim_count()
	var new_pos = get_parent().locations[new_coords].get_pos()
	var current_pos = get_parent().locations[self.coords].get_pos()
	var distance_length = (new_pos - current_pos).length()
	
	get_node("CorsairHook").animate_retract(distance_length, 600)
	yield(get_node("CorsairHook"), "animation_done")
	emit_signal("animation_done")
	subtract_anim_count()
	
func hook(new_coords):
	var adjacent_coords = get_parent().hex_normalize(new_coords - self.coords) + self.coords
	get_parent().pieces[new_coords].hooked(adjacent_coords)
	return adjacent_coords


func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
