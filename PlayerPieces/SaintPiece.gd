extends "PlayerPiece.gd"

const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_ARMOR_VALUE = 1
const UNIT_TYPE = "Saint"

var pathed_range


const OVERVIEW_DESCRIPTION = """1 Armor

Movement: 2 Range Step

Inspire: +Protect (Unit is invulnerable to damage until next turn. Can block Summoning Tiles.)
"""

const ATTACK_DESCRIPTION = """

Intervention. Target an ally within 2 range. If the tile immediately south of it is empty, move it to that tile.
"""

const PASSIVE_DESCRIPTION = """Purify. Move to a tile. All adjacent Enemy units which are already adjacent to another Player Unit are silenced."""

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
	var return_range = []
	for coords in unfiltered_range:
		if get_parent().locations.has(coords + Vector2(0, 1)) and !get_parent().pieces.has(coords + Vector2(0, 1)): #only return enemies with their backs open
			return_range.append(coords)
	return return_range


func get_intervention_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, self.movement_value], "PLAYER")
	var return_range = []
	for coords in unfiltered_range:
		if get_parent().locations.has(coords + Vector2(0, 1)) and !get_parent().pieces.has(coords + Vector2(0, 1)): #only return enemies with their backs open
			return_range.append(coords)
	return return_range


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	for coords in get_intervention_range():
		get_parent().get_at_location(coords).assist_highlight()

func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	
func _is_within_intervention_range(new_coords):
	return new_coords in get_intervention_range()

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
	yield(self, "animation_done")
	subtract_anim_count()
	
func animate_directly_above_purify(attack_coords):
	add_anim_count()
	var attack_location = get_parent().locations[attack_coords]
	var difference = 2 * (attack_location.get_pos() - get_pos())/3
	var attack_position = attack_location.get_pos() - difference
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	yield(self, "animation_done")
	subtract_anim_count()

func act(new_coords):
	if _is_within_attack_range(new_coords):
		handle_pre_assisted()
		intervene(new_coords)
		placed()
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [self.coords, new_coords, self.pathed_range, 300]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		purify_passive(new_coords)
		#imbue(new_coords)
		placed()
	elif _is_within_intervention_range(new_coords):
		handle_pre_assisted()
		intervene(new_coords)
		placed()
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
	#imbue(return_position)
	

func purify_passive(new_coords):
	var adjacent_enemy_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	var action = get_new_action(adjacent_enemy_range, false)
	action.add_call("set_silenced", [true])
	action.execute()


func intervene(new_coords):
	var piece = get_parent().pieces[new_coords]
	piece.move(Vector2(0, 1))
	piece.enqueue_animation_sequence()

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
