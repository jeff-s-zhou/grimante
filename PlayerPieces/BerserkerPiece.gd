
extends "PlayerPiece.gd"
#extends KinematicBody2D
const DAMAGE = 3
const AOE_DAMAGE = 2

const ANIMATION_STATES = {"default":0, "moving":1, "jumping":2}

var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Berserker"

const DESCRIPTION = ""

signal movement_animation_finished

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	get_node("ClickArea").set_monitorable(false)
	set_process_input(true)


#parameters to use for get_node("Grid").get_neighbors
func display_action_range():
	var neighbors = get_parent().get_radial_neighbors(self.coords)
	for neighbor in neighbors:
		neighbor.movement_highlight()

func animate_smash():
	get_node("AnimationPlayer").play("smash")
	#get_node("Tween").interpolate_callback(self, 0.1, "play_smash_sound")
	yield( get_node("AnimationPlayer"), "finished" )
	emit_signal("shake")
	
	
	emit_signal("movement_animation_finished")

func play_smash_sound():
	get_node("SamplePlayer2D").play("explode3")

func jump_to(new_coords, speed=4):
	set_z(2)
	self.mid_animation = true
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var speed = 400
	var time = distance/speed
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), new_position, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("AnimationPlayer").play("jump")
	yield( get_node("AnimationPlayer"), "finished" )
	get_node("AnimationPlayer").play("float")
	get_node("Tween").interpolate_callback(self, time - 0.2, "animate_smash")
	get_node("Tween").start()
	
	
func act(new_coords):
	if _is_within_range(new_coords):
		if get_parent().pieces.has(new_coords): #if there's a piece in the new coord
			if get_parent().pieces[new_coords].side == "ENEMY":
				smash_attack(new_coords)
				return true

		else: #else move to the location
			smash_move(new_coords)
			return true
	return false


func smash_attack(new_coords):
	if get_parent().pieces[new_coords].hp - DAMAGE <= 0:
		jump_to(new_coords)
		yield(self, "movement_animation_finished")
		get_parent().pieces[new_coords].smash_killed(DAMAGE)
		var neighbors = get_parent().get_neighbors(new_coords)
		smash(neighbors)
		set_coords(new_coords)
		placed()
		
	#else leap back
	else:
		jump_to(new_coords)
		yield(self, "movement_animation_finished")
		get_parent().pieces[new_coords].attacked(DAMAGE)
		jump_to(self.coords)
		yield(self, "movement_animation_finished")
		placed()


func smash_move(new_coords):
	jump_to(new_coords)
	yield(self, "movement_animation_finished")
	var neighbors = get_parent().get_neighbors(new_coords)
	smash(neighbors)
	set_coords(new_coords)
	placed()


func smash(neighbors):
	for neighbor in neighbors:
		if neighbor.has_method("attacked"):
			neighbor.attacked(AOE_DAMAGE)
			
func placed():
	set_z(-1)
	.placed()


func _is_within_range(new_coords):
	var neighbors = get_parent().get_radial_neighbors(self.coords)
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	



