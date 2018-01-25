extends "PlayerPiece.gd"

const DEFAULT_MOVEMENT_VALUE = 0
const DEFAULT_SHIELD = false
const UNIT_TYPE = "Saint"

var recorded_hero_coords = {}


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
	

func get_movement_range():
	var player_pieces =  get_tree().get_nodes_in_group("player_pieces")
	var fly_range = []
	for piece in player_pieces:
		if piece != self and piece.coords != null:
			fly_range += get_parent().get_range(piece.coords, [1, 2])
	
	if self.movement_value > 0:
		fly_range +=  get_parent().get_radial_range(self.coords, [1, self.movement_value])
	return fly_range

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
	
	
func get_lights_range():
	return self.grid.get_range(self.coords, [2, 8], "PLAYER") + self.grid.get_diagonal_range(self.coords, [2, 6], "PLAYER")
	

func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [new_coords]
		add_animation(self, "animate_intervention", true, args)
		set_coords(new_coords)
		silence(new_coords)
		placed()
	else:
		invalid_move()
		
func handle_break_chains(hero):
	#chain is already formed
	if self.recorded_hero_coords.has(hero.unit_name):
		pass

#called by the saint after it moves
func self_handle_field_of_lights():
	if self.state == States.DEAD:
		return
	
	for hero in get_tree().get_nodes_in_group("player_pieces"): #update here in case pieces have moved
		self.recorded_hero_coords[hero.unit_name] = hero.coords
	var lights_range = get_lights_range()
	for coords in lights_range:
		cast_field_of_lights(self.coords, coords)

#needs to be called after receiving shove
#needs to be called after a piece moves
func handle_field_of_lights(hero):
	if self.state == States.DEAD:
		return
	
	if (!self.recorded_hero_coords.has(hero.unit_name) 
	or hero.coords != self.recorded_hero_coords[hero.unit_name]): #check if the hero has moved
		self.recorded_hero_coords[hero.unit_name] = hero.coords
		var lights_range = get_lights_range()
		if hero.coords in lights_range:
			cast_field_of_lights(self.coords, hero.coords)


func cast_field_of_lights(start_coords, end_coords):
	
	var unit = self.grid.hex_normalize(end_coords - start_coords)
	var current_coords = start_coords + unit
	var attack_range = []
	while current_coords != end_coords:
		if self.grid.has_enemy(current_coords):
			attack_range.append(current_coords)
		current_coords += unit
		
	if attack_range != []:
		var start_pos = self.grid.locations[start_coords].get_pos()
		var end_pos = self.grid.locations[end_coords].get_pos()
		add_animation(self, "animate_cast_chain", true, [start_pos, end_pos])
	
	var action = get_new_action()
	action.add_call("attacked", [1, self], attack_range)
	action.execute()


func animate_cast_chain(start_pos, end_pos):
	var chains_prototype = load("res://PlayerPieces/Components/ChainsOfLight.tscn")
	var chains = chains_prototype.instance()
	add_child(chains)
	chains.draw_chains(start_pos, end_pos)
	yield(chains, "animation_done")
	emit_signal("animation_done")
	chains.explode()
	

func silence(new_coords):
	var adjacent_enemy_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	if adjacent_enemy_range != []:
		add_animation(self, "animate_silence", false)
	var action = get_new_action(false)
	action.add_call("set_silenced", [true], adjacent_enemy_range)
	action.execute()


func animate_silence():
	var ring = get_node("Physicals/SilenceRing")
	var explosion = get_node("Physicals/SilenceExplosion")
	ring.set_enabled(true)
	explosion.set_enabled(true)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(explosion, "energy", \
	2, 0.01, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(ring, "energy", \
	5, 0.01, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(ring, "transform/scale", \
	Vector2(0.3, 0.3), Vector2(1.6, 1.6), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	get_node("SamplePlayer 2").play("silence")
	yield(tween, "tween_complete")
	yield(tween, "tween_complete")
	yield(tween, "tween_complete")
	
	tween.queue_free()
	
	
#calls animate_move_to_pos as the last part of sequence
#animate_move_to_pos is what emits the required signals
func animate_intervention(new_coords):
	add_anim_count()
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("Flash"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	yield(get_node("Tween 2"), "tween_complete")
	emit_signal("animation_done")
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("Flash"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	subtract_anim_count()
	

func predict(new_coords):
	pass
