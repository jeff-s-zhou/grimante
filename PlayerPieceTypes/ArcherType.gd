
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/archer_piece.png"

var STATES = {"default":0, "moving":1}
var animation_state = STATES.default

var velocity
var new_position

signal animation_finished

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	

#parameters to use for get_node("Grid").get_neighbors
func display_action_range(coords, grid):
	var movement_neighbors = grid.get_neighbors(coords)
	for neighbor in movement_neighbors:
		neighbor.movement_highlight()
	
	var attack_neighbors = grid.get_neighbors(coords, [2, 11])
	for neighbor in attack_neighbors:
		neighbor.attack_highlight()
		
	var diagonal_attack_neighbors = grid.get_diagonal_neighbors(coords, [1, 8])
	for neighbor in diagonal_attack_neighbors:
		neighbor.attack_highlight()
	


func move_to(old_coords, new_coords, grid):
	var location = grid.locations[new_coords]
	new_position = location.get_pos()
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * 6
	self.animation_state = STATES.moving


func _fixed_process(delta):
	if self.animation_state == STATES.moving:
		var difference = (new_position - get_parent().get_pos()).length()
		if (difference < 6.0):
			self.animation_state = STATES.default
			get_parent().set_pos(new_position)
			emit_signal("animation_finished")
		else:
			get_parent().move(velocity) 


func act(old_coords, new_coords, grid):
	#returns whether the act was successfully committed
	var committed = false
	#if the tile selected is within movement range
	if _is_within_movement_range(old_coords, new_coords, grid):
		if grid.pieces.has(new_coords): 
			pass
		else: 
			committed = true
			regular_move(old_coords, new_coords, grid)
	
	#elif the tile selected is within attack range
	elif _is_within_attack_range(old_coords, new_coords, grid):
		ranged_attack(old_coords, new_coords, grid)
		committed = true
	else:
		move_to(old_coords, old_coords, grid)
	grid.reset_highlighting()
	return committed


func regular_move(old_coords, new_coords, grid):
	move_to(old_coords, new_coords, grid)
	yield(self, "animation_finished")
	get_parent().set_coords(new_coords)
	
	
func ranged_attack(old_coords, new_coords, grid):
	var difference = new_coords - old_coords
	var increment = grid.hex_normalize(difference)
	var current_coords = old_coords
	var units_travelled = 0
	while(units_travelled < 12):
		units_travelled += 1
		current_coords += increment
		if (grid.pieces.has(current_coords)):
			grid.pieces[current_coords].attacked(4)
			break
		
	



func _is_within_movement_range(old_coords, new_coords, grid):
	var neighbor_coords = []
	var movement_neighbors = grid.get_neighbors(old_coords)
	for neighbor in movement_neighbors:
		neighbor_coords.append(neighbor.coords)
		
	if new_coords in neighbor_coords:
		return true
	else:
		return false


func _is_within_attack_range(old_coords, new_coords, grid):
	var neighbor_coords = []
	var attack_neighbors = grid.get_neighbors(old_coords, [2, 11])
	for neighbor in attack_neighbors:
		neighbor_coords.append(neighbor.coords)
		
	var diagonal_attack_neighbors = grid.get_diagonal_neighbors(old_coords, [1, 9])
	for neighbor in diagonal_attack_neighbors:
		neighbor_coords.append(neighbor.coords)

	if new_coords in neighbor_coords:
		return true
	else:
		return false
	