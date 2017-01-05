
extends "PlayerPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/archer_piece.png"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

var SHOOT_DAMAGE = 3

var velocity
var new_position

var pathed_range

signal animation_finished

const UNIT_TYPE = "Archer"

const DESCRIPTION = """Armor: 0
Movement: 1 range step
Attack: Snipe. Attack the first enemy in a line for 4 damage. Can target diagonally. """
	
	
func _ready():
	self.armor = 0

func get_attack_range():
	var attack_range = get_parent().get_range(self.coords, [1, 11], "ENEMY", true)
	var attack_range_diagonal = get_parent().get_diagonal_range(self.coords, [1, 8], "ENEMY", true)
	return attack_range + attack_range_diagonal

func get_movement_range():
	self.pathed_range = get_parent().get_pathed_range(self.coords, 2)
	return self.pathed_range.keys()
	
func get_step_shot_coords(coords):
	var step_shot_range = get_parent().get_range(coords, [1, 11], "ENEMY", true, [0, 1])
	if step_shot_range.size() > 0:
		return step_shot_range[0]
	else:
		return null


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	if self.ultimate_flag:
		return
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
		
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()

func _is_within_attack_range(new_coords):
	return new_coords in get_attack_range()


func act(new_coords):
	#if the tile selected is within movement range
	if self.ultimate_flag:
		invalid_move()
	
	elif _is_within_movement_range(new_coords):
		var args = [self.coords, new_coords, self.pathed_range, 350]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
		set_coords(new_coords)
		var coords = get_step_shot_coords(self.coords)
		if coords != null:
			ranged_attack(coords)
		placed()

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		ranged_attack(new_coords)
		get_node("/root/Combat").handle_assassin_passive(new_coords)
		placed()
		
	else:
		invalid_move()

func ranged_attack(new_coords):
	print("calling ranged attack")
	get_node("/root/AnimationQueue").enqueue(self, "animate_ranged_attack", true, [new_coords])
	get_parent().pieces[new_coords].attacked(SHOOT_DAMAGE)


func animate_ranged_attack(new_coords):
	print("animating ranged attack")
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var angle = get_pos().angle_to_point(new_position)
	
	var arrow = get_node("ArcherArrow")
	arrow.set_rot(angle)
	var distance = get_pos().distance_to(new_position)
	var speed = 1800
	var time = distance/speed
	
	get_node("Tween 2").interpolate_property(arrow, "visibility/opacity", 0, 1, 0.6, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	var offset = Vector2(0, -10)
	var new_arrow_pos = (location.get_pos() - get_pos()) + offset
	
	#draw back
	get_node("SamplePlayer2D").play("bow_draw")
	var draw_back_position = arrow.get_pos() - (40 * (new_arrow_pos - arrow.get_pos()).normalized())
	get_node("Tween 2").interpolate_property(arrow, "transform/pos", arrow.get_pos(), draw_back_position, 1.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	get_node("Tween 2").interpolate_property(arrow, "transform/pos", arrow.get_pos(), new_arrow_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	print("time to fire arrow is " + str(time))
	get_node("Tween 2").interpolate_callback(self, time - 0.15, "play_bow_hit")
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	arrow.set_opacity(0)
	arrow.set_pos(offset)
	
	emit_signal("animation_done")

func play_bow_hit():
	get_node("SamplePlayer2D").play("bow_hit")

func predict(new_coords):
	if self.ultimate_flag:
		return
	
	elif _is_within_movement_range(new_coords):
		var coords = get_step_shot_coords(new_coords)
		if coords != null:
			predict_ranged_attack(coords, true)

	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		predict_ranged_attack(new_coords)


func predict_ranged_attack(new_coords, passive=false):
	get_parent().pieces[new_coords].predict(SHOOT_DAMAGE, passive)
	
	
func cast_ultimate():
	self.set_cooldown(2)
	print("casting ultimate")
	#first reset the highlighting on the parent nodes. Then call the new highlighting
	self.ultimate_flag = true
	display_overwatch()
	get_parent().reset_highlighting()
	get_node("BlueGlow").hide()
	get_parent().selected = null
	
func trigger_ultimate(attack_coords):
	if _is_within_attack_range(attack_coords):
		get_node("/root/AnimationQueue").enqueue(self, "animate_ranged_attack", true, [attack_coords])
		get_parent().pieces[attack_coords].nonlethal_attacked(3)
	
func display_overwatch():
	pass
