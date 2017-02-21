extends "PlayerPiece.gd"

const DEFAULT_FREEZE_DAMAGE = 1
const DEFAULT_SHIELD_BASH_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 1
const UNIT_TYPE = "Frost Knight"

var freeze_damage = DEFAULT_FREEZE_DAMAGE setget , get_freeze_damage
var shield_bash_damage = DEFAULT_SHIELD_BASH_DAMAGE setget , get_shield_bash_damage

const OVERVIEW_DESCRIPTION = """
"""

const ATTACK_DESCRIPTION = """
"""

const PASSIVE_DESCRIPTION = """"""

const ULTIMATE_DESCRIPTION = """"""

func _ready():
	self.armor = 1
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION


func get_freeze_damage():
	return self.attack_bonus + DEFAULT_FREEZE_DAMAGE

func get_shield_bash_damage():
	return self.attack_bonus + DEFAULT_SHIELD_BASH_DAMAGE

func get_movement_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1]) #locations only
	
func get_attack_range():
	return get_parent().get_range(self.coords, [1, self.movement_value + 1], "ENEMY")

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()

func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()


func act(new_coords):
	if _is_within_movement_range(new_coords):
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", true, [new_coords, 250, true])
		frostbringer(new_coords)
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		shield_bash(new_coords)
		placed()
	elif _is_within_ally_shove_range(new_coords):
		initiate_shove(new_coords)
		placed()
	else:
		invalid_move()


func shield_bash(new_coords):
	get_parent().pieces[new_coords].attacked(self.shield_bash_damage)
	var offset = get_parent().hex_normalize(new_coords - self.coords)
	var shove_destination_coords = new_coords + offset
		
	var location = get_parent().locations[new_coords]
	var difference = (location.get_pos() - get_pos()) / 3
	var collide_pos = get_pos() + difference 
	get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [collide_pos, 300, true]) #push up against it
	if get_parent().pieces.has(new_coords): #if the initial damage didn't kill it
		get_parent().pieces[new_coords].receive_shield_bash(shove_destination_coords)
	get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [new_coords, 300, false])
	frostbringer(new_coords)
	set_coords(new_coords)
	
func frostbringer(new_coords):
	#get enemies to the left
	var horizontal_range = get_parent().get_diagonal_range(new_coords, [1, 4], "ENEMY", false, [1, 2]) + \
	 get_parent().get_diagonal_range(new_coords, [1, 4], "ENEMY", false, [4, 5])
	
	for coords in horizontal_range:
		get_parent().pieces[coords].set_frozen(true)
		get_parent().pieces[coords].attacked(self.freeze_damage)
	
	


func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
