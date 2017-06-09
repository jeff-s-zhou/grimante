
extends "PlayerPiece.gd"

const UNIT_TYPE = "Stormdancer"

const ATTACK_DESCRIPTION = ["""Lightning Shuriken. Deal 1 damage to any enemy on the map.
"""]

const PASSIVE_DESCRIPTION = ["""Rain Dance. Moving to a tile casts Rain on the tile. 

Tango. Select an allied unit within movement range to swap positions with it.
"""]


const DEFAULT_BOLT_DAMAGE = 3
const DEFAULT_STORM_DAMAGE = 5
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_ARMOR_VALUE = 3

var bolt_damage = DEFAULT_BOLT_DAMAGE setget ,get_bolt_damage
var storm_damage = DEFAULT_STORM_DAMAGE setget ,get_storm_damage


var rain_coords_dict = {}

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.defense


	
func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
	self.AssistSystem.activate_assist(self.assist_type, self)
	

func deploy():
	get_parent().locations[self.coords].set_rain(true)
	self.rain_coords_dict[self.coords] = true
	.deploy()

func get_bolt_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_BOLT_DAMAGE

#not a true getter
func get_storm_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_STORM_DAMAGE
	

func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	

func get_ally_swap_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value], "PLAYER")
	
	
func get_enemy_swap_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range() + get_enemy_swap_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	for coords in get_ally_swap_range():
		get_parent().get_at_location(coords).assist_highlight()



func _is_within_movement_range(new_coords):
	var movement_range = get_movement_range()
	return new_coords in movement_range
	
func _is_within_swap_range(new_coords):
	var swap_range = get_ally_swap_range() + get_enemy_swap_range()
	return new_coords in swap_range


func act(new_coords):
	#returns whether the act was successfully committed
	if _is_within_swap_range(new_coords):
		handle_pre_assisted()
		tango(new_coords)
		placed()
		
	elif _is_within_movement_range(new_coords):
		handle_pre_assisted()
		add_animation(self, "animate_shunpo", true, [new_coords])
		get_parent().locations[new_coords].set_rain(true)
		self.rain_coords_dict[new_coords] = true
		set_coords(new_coords)
		placed()
	else:
		invalid_move()


func lightning_attack(attack_coords):
	get_parent().pieces[attack_coords].attacked(self.bolt_damage)
	

func tango(new_coords):
	add_animation(self, "animate_shunpo", true, [new_coords])
	var target = self.grid.pieces[new_coords]
	get_parent().locations[new_coords].set_rain(true)
	self.rain_coords_dict[new_coords] = true
	swap_coords_and_pos(target)
	if target.side == "ENEMY":
		target.handle_rain()
	
func animate_shunpo(new_coords):
	add_anim_count()
	get_node("AnimationPlayer 2").play("ShunpoOut")
	yield(get_node("AnimationPlayer 2"), "finished")
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	get_node("AnimationPlayer 2").play("ShunpoIn")
	yield(get_node("AnimationPlayer 2"), "finished")
	emit_signal("animation_done")
	subtract_anim_count()


func predict(new_coords):
	pass
