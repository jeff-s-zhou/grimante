
extends "PlayerPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/archer_piece.png"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

var velocity
var new_position

signal animation_finished

const UNIT_TYPE = "Archer"

const DESCRIPTION = ""

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	get_node("ClickArea").set_monitorable(false)
	set_process_input(true)

#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var movement_neighbors = get_parent().get_neighbors(self.coords)
	for neighbor in movement_neighbors:
		neighbor.movement_highlight()
	
	var attack_neighbors = get_parent().get_neighbors(self.coords, [2, 11])
	for neighbor in attack_neighbors:
		neighbor.attack_highlight()
		
	var diagonal_attack_neighbors = get_parent().get_diagonal_neighbors(self.coords, [1, 8])
	for neighbor in diagonal_attack_neighbors:
		neighbor.attack_highlight()

func act(new_coords):

	#if the tile selected is within movement range
	if _is_within_movement_range(new_coords):
		if get_parent().pieces.has(new_coords): 
			return false
		else: 
			regular_move(new_coords)
			return true
	
	#elif the tile selected is within attack range
	elif _is_within_attack_range(new_coords):
		ranged_attack(new_coords)
		return true

	return false


func regular_move(new_coords):
	animate_move(new_coords)
	yield(get_node("Tween"), "tween_complete")
	placed()
	set_coords(new_coords)
	
	
func ranged_attack(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	var current_coords = self.coords
	var units_travelled = 0
	while(units_travelled < 12):
		units_travelled += 1
		current_coords += increment
		if (get_parent().pieces.has(current_coords)):
			if (get_parent().pieces[current_coords].side == "ENEMY"):
				get_parent().pieces[current_coords].attacked(4)
			break



func _is_within_movement_range(new_coords):
	var neighbor_coords = []
	var movement_neighbors = get_parent().get_neighbors(self.coords)
	for neighbor in movement_neighbors:
		neighbor_coords.append(neighbor.coords)
		
	if new_coords in neighbor_coords:
		return true
	else:
		return false


func _is_within_attack_range(new_coords):
	var neighbor_coords = []
	var attack_neighbors = get_parent().get_neighbors(self.coords, [2, 11])
	for neighbor in attack_neighbors:
		neighbor_coords.append(neighbor.coords)
		
	var diagonal_attack_neighbors = get_parent().get_diagonal_neighbors(self.coords, [1, 9])
	for neighbor in diagonal_attack_neighbors:
		neighbor_coords.append(neighbor.coords)

	if new_coords in neighbor_coords:
		return true
	else:
		return false
	