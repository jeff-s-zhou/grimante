extends "PlayerPiece.gd"

const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_SHIELD = false
const UNIT_TYPE = "Crusader"

const BASE_HOLY_BLADE_DAMAGE = 3

var alter_ego

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.defense
	

#don't add to player_pieces group on initialization
func initialize(cursor_area):
	self.cursor_area = cursor_area

	
func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
	self.AssistSystem.activate_assist(self.assist_type, self)
	
func get_holy_blade_damage(coords):
	var damage = BASE_HOLY_BLADE_DAMAGE
	
	var self_pos = get_parent().locations[coords].get_pos()
	
	#add one damage for each player piece that's behind the Saint
	var player_pieces = get_tree().get_nodes_in_group("player_pieces")
	for player_piece in player_pieces:
		var position = get_parent().locations[player_piece.coords].get_pos()
		if position.y > self_pos.y and player_piece.unit_name != "Crusader":
			damage += 1
			
	return damage

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])

	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")
	var return_range = []
	
	var directly_above_coords = self.coords + Vector2(0, -1)
	if (directly_above_coords in unfiltered_range): #catch the piece immediately above crusader
		return_range.append(directly_above_coords)
	
	for coords in unfiltered_range:
		if get_parent().locations.has(coords + Vector2(0, 1)) and !get_parent().pieces.has(coords + Vector2(0, 1)): #only return enemies with their backs open
			return_range.append(coords)
	return return_range

#if we've reached the bottom of the map
func transform():
	for i in range(0, 7):
		if self.coords == get_parent().get_bottom_of_column(i):
			switch_out()
			return true
	return false


func switch_out():
	purify_passive(self.coords)
	remove_from_group("player_pieces")
	get_parent().remove_piece(self.coords)
	add_animation(self, "animate_switch_out", true)
	self.alter_ego.switch_in(self.coords)
			
func switch_in(coords):
	self.AssistSystem.clear_assist()
	add_to_group("player_pieces")
	get_parent().add_piece(coords, self, true)
	var pos = get_parent().locations[coords].get_pos()
	add_animation(self, "animate_switch_in", true, [pos])
	placed()
	
func animate_switch_out():
	add_anim_count()
	get_node("Tween 2").interpolate_property(get_node("Flash"), "visibility/opacity", 0, 1, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	set_pos(Vector2(-999, -999))
	emit_signal("animation_done")
	subtract_anim_count()
	
func animate_switch_in(pos):
	set_opacity(1)
	#set_pos(pos)
	print(get_global_pos())
	get_node("Tween 2").interpolate_property(get_node("Flash"), "visibility/opacity", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	emit_signal("animation_done")


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
	get_node("Tween 2").interpolate_property(get_node("Flash"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	yield(get_node("Tween 2"), "tween_complete")
	var location = get_parent().locations[position_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	
	var attack_location = get_parent().locations[attack_coords]
	var difference = 3 * (attack_location.get_pos() - get_pos())/4
	var attack_position = attack_location.get_pos() - difference
	
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("Flash"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	yield(self, "animation_done")
	subtract_anim_count()


func animate_directly_above_purify(attack_coords):
	add_anim_count()
	var attack_location = get_parent().locations[attack_coords]
	var difference = 3 * (attack_location.get_pos() - get_pos())/4
	var attack_position = attack_location.get_pos() - difference
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	yield(self, "animation_done")
	subtract_anim_count()


func act(new_coords):
	if _is_within_attack_range(new_coords):
		handle_pre_assisted()
		purify(new_coords)
		placed()
	elif _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [new_coords, 300, true]
		add_animation(self, "animate_move_and_hop", true, args)
		set_coords(new_coords)
		var transformed = transform()
		if !transformed:
			placed()
	else:
		invalid_move()


func purify(new_coords):
	if new_coords == self.coords + Vector2(0, -1):
		add_animation(self, "animate_directly_above_purify", true, [new_coords])
	else:
		add_animation(self, "animate_purify", true, [new_coords])
	var action = get_new_action()
	action.add_call("set_silenced", [true], new_coords)
	action.add_call("attacked", [get_holy_blade_damage(new_coords + Vector2(0, 1))], new_coords)
	action.execute()
	var return_position = get_parent().locations[new_coords + Vector2(0, 1)].get_pos()
	add_animation(self, "animate_move_to_pos", true, [return_position, 200, true])
	set_coords(new_coords + Vector2(0, 1))
	

func purify_passive(new_coords):
	var adjacent_enemy_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	var action = get_new_action(false)
	action.add_call("set_silenced", [true], adjacent_enemy_range)
	action.execute()


func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass
