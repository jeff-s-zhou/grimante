
extends "PlayerPiece.gd"

const UNIT_TYPE = "Stormdancer"
const DESCRIPTION = """Unarmored

Movement: 2 range leap

Attack. Lightning Strike. Deal 1 damage to any enemy on the map.

Passive: Rain Dance. Moving to a tile casts Rain on the tile. 

Passive: Tango. Select an allied unit within movement range to swap positions with it.

Ultimate: Storm. Deal damage to enemies on Rain tiles equal to the number of Rain Tiles on the map. Stun all enemies hit. Rain tiles that dealt damage disappear.
"""


const DEFAULT_BOLT_DAMAGE = 1
const DEFAULT_MOVEMENT_VALUE = 2

var bolt_damage = DEFAULT_BOLT_DAMAGE setget ,get_bolt_damage


var rain_coords_dict = {}

func _ready():
	self.armor = 0
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.hover_description = DESCRIPTION
	self.check_global_seen()

func get_bolt_damage():
	return self.attack_bonus + DEFAULT_BOLT_DAMAGE

#not a true getter
func get_storm_damage(num_rain_tiles):
	return self.attack_bonus + num_rain_tiles
	

func set_coords(coords):
	get_parent().locations[coords].set_rain(true)
	self.rain_coords_dict[coords] = true
	.set_coords(coords)

func get_attack_range():
	return get_parent().get_all_range("ENEMY")


func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value + 1])


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_movement_range() + get_attack_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()


func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range


func _is_within_movement_range(new_coords):
	var movement_range = get_movement_range()
	return new_coords in movement_range


func act(new_coords):
	#returns whether the act was successfully committed
	
	if _is_within_attack_range(new_coords):
		get_node("/root/Combat").handle_archer_ultimate(new_coords)
		lightning_attack(new_coords)
		get_node("/root/Combat").handle_assassin_passive(new_coords)
		placed()
		
	elif _is_within_movement_range(new_coords):
		shunpo(new_coords)
		set_coords(new_coords)
		placed()
	else:
		invalid_move()


func lightning_attack(attack_coords):
	get_parent().pieces[attack_coords].attacked(self.bolt_damage)


func shunpo(new_coords):
	get_node("/root/AnimationQueue").enqueue(self, "animate_shunpo", true, [new_coords])
	set_coords(new_coords)
	
func animate_shunpo(new_coords):
	get_node("AnimationPlayer").play("ShunpoOut")
	yield(get_node("AnimationPlayer"), "finished")
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	get_node("AnimationPlayer").play("ShunpoIn")
	yield(get_node("AnimationPlayer"), "finished")
	emit_signal("animation_done")


func predict(new_coords):
	if _is_within_attack_range(new_coords):
		get_parent().pieces[new_coords].predict(self.bolt_damage)
		
	elif _is_within_movement_range(new_coords):
		pass


func cast_ultimate():
	self.ultimate_used_flag = true
	get_node("/root/AnimationQueue").enqueue(get_node("/root/Combat"), "darken", true)
	for coords in self.rain_coords_dict:
		if get_parent().pieces.has(coords) and get_parent().pieces[coords].side == "ENEMY":
			get_parent().locations[coords].activate_lightning()
			get_parent().pieces[coords].set_stunned(true)
			get_parent().pieces[coords].attacked(get_storm_damage(self.rain_coords_dict.size()))
	get_node("/root/AnimationQueue").enqueue(get_node("/root/Combat"), "lighten", true)