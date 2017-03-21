extends "PlayerPiece.gd"

const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_ARMOR_VALUE = 2
const UNIT_TYPE = "Saint"

var pathed_range


const OVERVIEW_DESCRIPTION = """
"""

const ATTACK_DESCRIPTION = """
"""

const PASSIVE_DESCRIPTION = """"""

const ULTIMATE_DESCRIPTION = """"""

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.invulnerable
	
func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
	self.AssistSystem.activate_assist(self.assist_type, self)

func get_movement_range():
	self.pathed_range = get_parent().get_pathed_range(self.coords, self.movement_value)
	return self.pathed_range.keys()
	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")
	var attack_range = []
	var directly_above_coords = self.coords + Vector2(0, -1)
	if (directly_above_coords in unfiltered_range): #catch the piece immediately above the saint
		attack_range.append(directly_above_coords)
	for coords in unfiltered_range:
		if get_parent().locations.has(coords + Vector2(0, 1)) and !get_parent().pieces.has(coords + Vector2(0, 1)): #only return enemies with their backs open
			attack_range.append(coords)
			
	return attack_range

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

#calls animate_move_to_pos as the last part of sequence
#animate_move_to_pos is what emits the required signals
func animate_purify(attack_coords):
	add_anim_count()
	var position_coords = attack_coords + Vector2(0, 1)

	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("SaintFlash"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	yield(get_node("Tween 2"), "tween_complete")
	var location = get_parent().locations[position_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	
	var attack_location = get_parent().locations[attack_coords]
	var difference = 2 * (attack_location.get_pos() - get_pos())/3
	var attack_position = attack_location.get_pos() - difference
	
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("SaintFlash"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	subtract_anim_count()
	
func animate_directly_above_purify(attack_coords):
	add_anim_count()
	var attack_location = get_parent().locations[attack_coords]
	var difference = 2 * (attack_location.get_pos() - get_pos())/3
	var attack_position = attack_location.get_pos() - difference
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	subtract_anim_count()

func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [self.coords, new_coords, self.pathed_range, 300]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		imbue(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		purify(new_coords)
		placed()
	elif _is_within_ally_shove_range(new_coords):
		handle_pre_assisted()
		initiate_friendly_shove(new_coords)
	else:
		invalid_move()


func purify(new_coords):
	if new_coords == self.coords + Vector2(0, -1):
		get_node("/root/AnimationQueue").enqueue(self, "animate_directly_above_purify", true, [new_coords])
	else:
		get_node("/root/AnimationQueue").enqueue(self, "animate_purify", true, [new_coords])
	var action = get_new_action(new_coords)
	action.add_call("set_silenced", [true])
	action.execute()
	var return_position = get_parent().locations[new_coords + Vector2(0, 1)].get_pos()
	get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [return_position, 200, true])
	set_coords(new_coords + Vector2(0, 1))
	imbue(return_position)
	
func armored_cross(new_coords):
	pass

	
func imbue(new_coords):
	pass

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
