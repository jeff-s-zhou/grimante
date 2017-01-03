
extends "PlayerPiece.gd"


var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const TRAMPLE_DAMAGE = 2

const UNIT_TYPE = "Stormdancer"
const DESCRIPTION = """
"""

const DEFAULT_BOLT_DAMAGE = 1

var bolt_damage = DEFAULT_BOLT_DAMAGE

func _ready():
	self.armor = 0

func set_coords(coords):
	get_parent().locations[coords].set_rain(true)
	.set_coords(coords)

func get_attack_range():
	return get_parent().get_all_range("ENEMY")


func get_movement_range():
	return get_parent().get_radial_range(self.coords)


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
		
	elif _is_within_movement_range(new_coords):
		shunpo(new_coords)
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
		pass
		
	elif _is_within_movement_range(new_coords):
		pass



func cast_ultimate():
	pass