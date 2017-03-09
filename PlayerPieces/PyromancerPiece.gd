extends "PlayerPiece.gd"

const DEFAULT_WILDFIRE_DAMAGE = 2
const DEFAULT_MOVEMENT_VALUE = 1
const DEFAULT_ARMOR_VALUE = 1
const UNIT_TYPE = "Pyromancer"

const flask_prototype = preload("res://PlayerPieces/Components/PyromancerFlask.tscn")

var wildfire_damage = DEFAULT_WILDFIRE_DAMAGE setget , get_wildfire_damage

const OVERVIEW_DESCRIPTION = """
"""

const ATTACK_DESCRIPTION = """
"""

const PASSIVE_DESCRIPTION = """"""

const ULTIMATE_DESCRIPTION = """"""

var pathed_range

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.attack

func get_wildfire_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_WILDFIRE_DAMAGE


func get_movement_range():
	self.pathed_range = get_parent().get_pathed_range(self.coords, self.movement_value)
	return self.pathed_range.keys()
	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, 3], "ENEMY")
	return unfiltered_range

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
		set_invulnerable()
		var args = [self.coords, new_coords, self.pathed_range, 350]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		set_invulnerable()
		get_node("/root/AnimationQueue").enqueue(self, "animate_bomb", true, [new_coords])
		bomb(new_coords)
		placed()
	elif _is_within_ally_shove_range(new_coords):
		set_invulnerable()
		initiate_friendly_shove(new_coords)
	else:
		invalid_move()
		
func animate_bomb(coords):
	var flask = flask_prototype.instance()
	add_child(flask)
	var flask_components = flask.get_node("Components")
	flask_components.set_rotd(-15)
	flask_components.get_node("Flask").show()
	
	get_node("Tween").interpolate_property(flask_components, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	
	animate_toss(flask)
	
	var target_pos = (get_parent().locations[coords].get_pos() - get_pos())
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


func animate_toss(flask):
	var final_height = flask.get_pos() + Vector2(0, -300)
	get_node("Tween 2").interpolate_property(flask, "transform/pos", Vector2(0, 0), final_height, 0.4, Tween.TRANS_QUAD, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	get_node("Tween 2").interpolate_property(flask, "transform/pos", final_height, Vector2(0, 0), 0.4, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween 2").start()


func bomb(new_coords):
	var action = get_new_action(new_coords)
	action.add_call("set_burning", [true])
	action.add_call("attacked", [self.wildfire_damage])
	action.execute()
	
	var nearby_enemy_range = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	var nearby_enemy_range_filtered = []
	for coords in nearby_enemy_range:
		if !get_parent().pieces[coords].burning:
			nearby_enemy_range_filtered.append(coords)
	if nearby_enemy_range_filtered.size() > 0:
		var random_index = randi() % nearby_enemy_range_filtered.size()
		var spread_coords = nearby_enemy_range_filtered[random_index]
		bomb(spread_coords)
		

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		pass

func cast_ultimate():
	pass
