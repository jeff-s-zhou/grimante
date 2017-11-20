extends "PlayerPiece.gd"

const DEFAULT_FIREBALL_DAMAGE = 3
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_SHIELD = false
const UNIT_TYPE = "Pyromancer"

const fireball_prototype = preload("res://PlayerPieces/Components/FireballTrue.tscn")

var fireball_damage = DEFAULT_FIREBALL_DAMAGE setget , get_fireball_damage

var pathed_range

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.attack

func get_fireball_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_FIREBALL_DAMAGE


func get_movement_range():
	var movement_range = get_parent().get_radial_range(self.coords, [1, self.movement_value])
	return movement_range
	
func get_attack_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")
	
func highlight_indirect_range(movement_range):
	pass

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	highlight_indirect_range(action_range)
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	
func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()
	
func get_bomb_coords(new_coords):
	pass

func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		firestorm(new_coords)
		placed()
	else:
		invalid_move()

func gather_charges(coords):
	var charge_range = self.grid.get_range(self.coords, [1, 2])
	if coords in charge_range:
		get_node("Physicals/PyromancerCharges").add_charge(1)

func firestorm(coords):
	randomize()
	var charge = get_node("Physicals/PyromancerCharges").get_charge()
	if charge:
		add_animation(self, "animate_start_firestorm", false)
		cast_fireball(coords)
		while get_node("Physicals/PyromancerCharges").get_charge():
			var target = get_random_target()
			if target:
				cast_fireball(target.coords)
		add_animation(self, "animate_end_firestorm", false)

func animate_start_firestorm():
	darken(0.3, 0.5)
	
func animate_end_firestorm():
	lighten(0.3)

func get_random_target():
	randomize()
	var random_range = self.grid.get_radial_range(self.coords, [1, 2], "ANY")
	var random_targets = []
	for coords in random_range:
		if self.grid.has_piece(coords):
			random_targets.append(self.grid.get_piece(coords))
	if random_targets != []:
		var selector = randi() % random_targets.size()
		return random_targets[selector]

func cast_fireball(coords):
	add_animation(self, "animate_cast_fireball", true, [coords])
	self.grid.get_piece(coords).fireball_attacked(self.fireball_damage, self)
	
	
func animate_cast_fireball(coords):
	add_anim_count()
	print("animating cast fireball")
	var fireball = self.fireball_prototype.instance()
	fireball.set_pos(Vector2(550, -900))
	var location_pos = self.grid.locations[coords].get_pos()
	var angle = location_pos.angle_to_point(fireball.get_pos())
	fireball.set_rot(angle)
	fireball.set_scale(Vector2(1, 2.5))
	get_parent().add_child(fireball)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(fireball, "transform/pos", fireball.get_pos(), location_pos, 0.8, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property(fireball, "transform/scale", Vector2(1, 2.5), Vector2(1, 1.5), 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.6)
	tween.start()
	yield(tween, "tween_complete")
	emit_signal("big_shake")
	emit_signal("animation_done")
	tween.queue_free()
	fireball.queue_free()
	subtract_anim_count()


func bomb(new_coords, count=0):
	var action = get_new_action()
	action.add_call("set_burning", [true], new_coords)
	action.add_call("attacked", [self.wildfire_damage], new_coords)
	action.execute()
	
	var surrounding_enemy_coords = get_parent().get_range(new_coords, [1, 2], "ENEMY")
	action = get_new_action()
	action.add_call("set_burning", [true], surrounding_enemy_coords)
	action.execute()


func predict(new_coords):
	pass

