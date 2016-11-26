
extends "PlayerPiece.gd"
#extends KinematicBody2D
# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/cavalier_piece.png"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

signal cavalier_animation_finished

const UNIT_TYPE = "Cavalier"
const DESCRIPTION = ""

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	get_node("ClickArea").set_monitorable(false)
	set_process_input(true)

func animate_attack(attack_coords):
	var location = get_parent().locations[attack_coords]
	var new_position = location.get_pos() - ((location.get_pos() - get_pos()) / 2)
	animate_move_to_pos(new_position, 300)
	
func animate_attack_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300)


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var neighbors = get_parent().get_neighbors(self.coords, [1, 11])
	for neighbor in neighbors:
		neighbor.movement_highlight()


func act(new_coords):
	#returns whether the act was successfully committed

	if _is_within_range(new_coords):
		#if there's a piece in the new coord
		if get_parent().pieces.has(new_coords) \
		and get_parent().pieces[new_coords].side == "ENEMY":
			if _is_within_range(new_coords, [1, 2]): #but it's not adjacent
				return false
			charge_move(new_coords, true)
			print ("doing stuff after")
			return true
		else: #else move to the location
			charge_move(new_coords)
			return true
	return false


func charge_move(new_coords, attack=false):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	var target_coords = new_coords
	
	#if attacking an enemy at the end, charge up to the square before their tile
	if(attack):
		target_coords = new_coords - increment
	
	animate_move(target_coords, 300)
	yield(get_node("Tween"), "tween_complete")
	
	
	var current_coords = self.coords + increment
	
	var tiles_passed = 1
	#deal damage to every tile you passed over
	while(current_coords != target_coords):
		if get_parent().pieces.has(current_coords) and get_parent().pieces[current_coords].side == "ENEMY":
			get_parent().pieces[current_coords].attacked(1)
			
		tiles_passed += 1
		current_coords = current_coords + increment
		
	if attack and get_parent().pieces.has(new_coords) and get_parent().pieces[new_coords].side == "ENEMY":
		animate_attack(new_coords)
		yield(get_node("Tween"), "tween_complete")
		get_parent().pieces[new_coords].attacked(tiles_passed)
		animate_attack_end(target_coords)
	
	set_coords(target_coords)
	placed()
	

	
func _is_within_range(new_coords, action_range=[1, 11]):
	var neighbors = get_parent().get_neighbors(self.coords, action_range)
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	

