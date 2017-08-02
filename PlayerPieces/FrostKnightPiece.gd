extends "PlayerPiece.gd"

const DEFAULT_FREEZE_DAMAGE = 2
const DEFAULT_SHIELD_BASH_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 1
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
	return get_parent().get_range(self.coords, [1, self.movement_value + 1]) #locations only
	
func get_attack_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1], "ENEMY")

func get_assist_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1], "PLAYER")

func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
	self.AssistSystem.activate_assist(self.assist_type, self)
	
func turn_update():
	.turn_update()
	set_shield(true)

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
		shield_bash(new_coords, false)
		placed()
	else:
		invalid_move()


func shield_bash(new_coords, freeze=true):
	if freeze:
		var action = get_new_action()
		action.add_call("set_frozen", [true], new_coords)
		action.execute()
	#var offset = get_parent().hex_normalize(new_coords - self.coords)
	print("in shield bash")
	#print(offset)
	move(new_coords - self.coords)
	enqueue_animation_sequence()
	frostbringer(new_coords)
	
func frostbringer(new_coords):
	#get enemies to the left and right
	add_animation(self, "animate_frostbringer", false, [new_coords])
	var horizontal_range = get_horizontal_range(new_coords)
	var action = get_new_action()
	action.add_call("set_frozen", [true], horizontal_range)
	action.execute()
	
func animate_frostbringer(new_coords):
	get_parent().get_node("FieldEffects").emit_frost(new_coords)
	

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
