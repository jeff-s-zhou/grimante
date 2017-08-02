extends "PlayerPiece.gd"

const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_SHIELD = false
const UNIT_TYPE = "Saint"

var pathed_range

var alter_ego

const CrusaderPrototype = preload("res://PlayerPieces/CrusaderPiece.tscn")

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.defense
	
func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
	self.AssistSystem.activate_assist(self.assist_type, self)
	
func initialize(cursor_area):
	self.alter_ego = CrusaderPrototype.instance()
	self.alter_ego.alter_ego = self
	self.alter_ego.set_pos(Vector2(-999, -999))
	get_node("/root/Combat").initialize_crusader(self.alter_ego)
	.initialize(cursor_area)

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])


func highlight_indirect_range(movement_range):
	var indirect_range = []
	var enemies = get_tree().get_nodes_in_group("enemy_pieces")
	for enemy in enemies:
		var adjacent_range = get_parent().get_radial_range(enemy.coords, [1, 1])
		for coords in adjacent_range:
			if coords in movement_range:
				get_parent().locations[coords].indirect_highlight()

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	highlight_indirect_range(action_range)

	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	

func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [new_coords, 300, true]
		add_animation(self, "animate_move_and_hop", true, args)
		set_coords(new_coords)
		var transformed = transform()
		purify_passive(new_coords)
		if !transformed:
			placed()
	else:
		invalid_move()
	

func purify_passive(new_coords):
	var adjacent_enemy_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	var action = get_new_action(false)
	action.add_call("set_silenced", [true], adjacent_enemy_range)
	action.execute()


#if we've reached the top of the map
func transform():
	for i in range(0, 7):
		if self.coords == get_parent().get_top_of_column(i):
			switch_out()
			return true
	return false
	
func switch_out():
	remove_from_group("player_pieces")
	get_parent().remove_piece(self.coords)
	add_animation(self, "animate_switch_out", true)
	
	print("saint's global pos is " + str(get_parent().locations[self.coords].get_global_pos()))
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
	

func predict(new_coords):
	pass
