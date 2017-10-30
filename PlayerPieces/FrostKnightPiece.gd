extends "PlayerPiece.gd"

const DEFAULT_FREEZE_DAMAGE = 2
const DEFAULT_SHIELD_BASH_DAMAGE = 4
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_SHIELD = true
const UNIT_TYPE = "Frost Knight"

var freeze_damage = DEFAULT_FREEZE_DAMAGE setget , get_freeze_damage
var shield_bash_damage = DEFAULT_SHIELD_BASH_DAMAGE setget , get_shield_bash_damage

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description("frostknight")
	self.assist_type = ASSIST_TYPES.defense

func get_freeze_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_FREEZE_DAMAGE

func get_shield_bash_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_SHIELD_BASH_DAMAGE

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	
func get_attack_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1], "ENEMY", true)

func get_assist_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1], "PLAYER", true)

func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
	self.AssistSystem.activate_assist(self.assist_type, self)

#func turn_update():
#	.turn_update()
#	set_shield(true)

func get_horizontal_range(new_coords):
	return get_parent().get_diagonal_range(new_coords, [1, 4], "ENEMY", false, [1, 2]) + \
	 get_parent().get_diagonal_range(new_coords, [1, 4], "ENEMY", false, [4, 5])
	
func highlight_indirect_range(movement_range):
	for coords in movement_range:
		if get_horizontal_range(coords) != []:
			get_parent().locations[coords].indirect_highlight()

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var movement_range = get_movement_range()
	var action_range = get_attack_range() + movement_range
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	for coords in get_assist_range():
		get_parent().get_at_location(coords).assist_highlight()
	.display_action_range()
	highlight_indirect_range(movement_range)

func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	
func _is_within_assist_range(new_coords):
	return new_coords in get_assist_range()


func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [new_coords, 250, true]
		add_animation(self, "animate_move_and_hop", true, args)
		frostbringer(new_coords)
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		shield_bash(new_coords)
		placed()
	elif _is_within_assist_range(new_coords):
		handle_pre_assisted()
		shield_bash(new_coords)
		placed()
	else:
		invalid_move()


func shield_bash(new_coords):
	var target = get_parent().pieces[new_coords]
	#var hex_length = get_parent().hex_length(new_coords - self.coords)
	var unit_distance = get_parent().hex_normalize(new_coords - self.coords)
	var unit_pos_distance = get_parent().get_real_distance(unit_distance)
	
	var new_pos = get_parent().locations[new_coords].get_pos()
	
	var back_up_pos = self.get_pos() - unit_pos_distance/4
	var shove_pos = new_pos - 2 * unit_pos_distance/4
	var original_pos = get_parent().locations[new_coords - unit_distance].get_pos()
	
	var arguments = [back_up_pos, 100, true, Tween.TRANS_QUAD, Tween.EASE_OUT]
	add_animation(self, "animate_move_to_pos", true, arguments)
	
	arguments = [shove_pos, 700, true, Tween.TRANS_SINE, Tween.EASE_IN]
	add_animation(self, "animate_move_to_pos", true, arguments)
	
	if target.side == "ENEMY":
		print("freezing?")
		var action = get_new_action(false)
		action.add_call("set_frozen", [true], new_coords)
		action.execute()
	
	target.receive_shove(unit_distance, self.shield_bash_damage)

	add_animation(self, "animate_move_to_pos", true, [original_pos, 200, true])
	
	#if we moved, freeze shit
	if self.coords != new_coords - unit_distance:
		frostbringer(new_coords - unit_distance)
		set_coords(new_coords - unit_distance)
	
	
func frostbringer(new_coords):
	#get enemies to the left and right
	add_animation(self, "animate_frostbringer", false, [new_coords])
	var horizontal_range = get_horizontal_range(new_coords)
	var action = get_new_action(false)
	action.add_call("set_frozen", [true], horizontal_range)
	action.execute()
	
func animate_frostbringer(new_coords):
	get_parent().get_node("FieldEffects").emit_frost(new_coords)
	

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
