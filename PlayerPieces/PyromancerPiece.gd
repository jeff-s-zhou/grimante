extends "PlayerPiece.gd"

const DEFAULT_WILDFIRE_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_ARMOR_VALUE = 0
const UNIT_TYPE = "Pyromancer"

const flask_prototype = preload("res://PlayerPieces/Components/PyromancerFlask.tscn")

var wildfire_damage = DEFAULT_WILDFIRE_DAMAGE setget , get_wildfire_damage

var pathed_range

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.attack

func get_wildfire_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_WILDFIRE_DAMAGE


func get_movement_range():
	var movement_range = get_parent().get_range(self.coords, [1,self.movement_value + 1], null, false, [-1, 2])
	if self.movement_value == 2:
		movement_range += get_parent().get_diagonal_range(self.coords, [1,2], null, false, [-1, 1])
	return movement_range
	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, self.movement_value + 1], "ENEMY")
	return unfiltered_range
	
func highlight_indirect_range(movement_range):
	for coords in movement_range:
		var bomb_coords = get_bomb_coords(coords)
		if bomb_coords != null:
			get_parent().locations[coords].indirect_highlight()

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	highlight_indirect_range(action_range)

func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	
func get_bomb_coords(new_coords):
	var line_range = self.grid.get_line_range(self.coords, new_coords - self.coords, "ENEMY")
	if line_range != []:
		return line_range[0]
	else:
		return null


func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		
		var args = [new_coords, 350, true]
		add_animation(self, "animate_move_and_hop", true, args)
		var bomb_coords = get_bomb_coords(new_coords)
		if bomb_coords != null:
			add_animation(self, "animate_bomb", true, [bomb_coords])
			bomb(bomb_coords)
		set_coords(new_coords)
		placed()
#	elif _is_within_attack_range(new_coords):
#		handle_pre_assisted()
#		add_animation(self, "animate_bomb", true, [new_coords])
#		bomb(new_coords)
#		reset_currently_burning()
#		placed()
	else:
		invalid_move()
		
func animate_bomb(coords):
	add_anim_count()
	var flask = flask_prototype.instance()
	add_child(flask)
	var flask_components = flask.get_node("Components")
	flask_components.set_rotd(-15)
	flask_components.set_pos(flask_components.get_pos() + Vector2(0, -10))
	flask_components.get_node("Flask").show()
	
	get_node("Tween").interpolate_property(flask_components, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	
	sub_animate_toss(flask)
	
	var target_pos = (get_parent().locations[coords].get_pos() - get_pos()) + Vector2(5, -10)
	var final_rotd = flask_components.get_rotd() - 45
	
	get_node("Tween").interpolate_property(flask_components, "transform/pos", flask_components.get_pos(), target_pos, 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").interpolate_property(flask_components, "transform/rot", flask_components.get_rotd(), final_rotd, 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	
	flask_components.get_node("Flask").hide()
	flask_components.get_node("Glass").set_emitting(true)
	get_node("Timer").set_wait_time(0.2)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	flask_components.get_node("Glass").set_emitting(false)
	get_node("Timer").set_wait_time(0.3)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	remove_child(flask)
	
	emit_signal("animation_done")
	subtract_anim_count()


func sub_animate_toss(flask):
	var final_height = flask.get_pos() + Vector2(0, -300)
	get_node("Tween 2").interpolate_property(flask, "transform/pos", Vector2(0, 0), final_height, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	get_node("Tween 2").interpolate_property(flask, "transform/pos", final_height, Vector2(0, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween 2").start()


func bomb(new_coords, count=0):
	var action = get_new_action()
	action.add_call("set_burning", [true], new_coords)
	action.add_call("attacked", [self.wildfire_damage], new_coords)
	action.execute()
	
	if count < 2:
		var nearby_enemy_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
		var nearby_enemy_range_filtered = []
		for coords in nearby_enemy_range:
			if !get_parent().pieces[coords].currently_burning:
				nearby_enemy_range_filtered.append(coords)
		if nearby_enemy_range_filtered.size() > 0:
			var random_index = randi() % nearby_enemy_range_filtered.size()
			var spread_coords = nearby_enemy_range_filtered[random_index]
			bomb(spread_coords, count + 1)
		
func reset_currently_burning():
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	for enemy_piece in enemy_pieces:
		enemy_piece.currently_burning = false

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
