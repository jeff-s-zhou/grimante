
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/cavalier_piece.png"

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
	var neighbors = grid.get_neighbors(coords, [1, 11])
	for neighbor in neighbors:
		neighbor.movement_highlight()


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
	if _is_within_range(old_coords, new_coords, grid):
		if grid.pieces.has(new_coords): #if there's a piece in the new coord
				if grid.pieces[new_coords].side == "ENEMY":
					committed = true
					charge_move(old_coords, new_coords, grid, true)
				else:
					move_to(old_coords, old_coords, grid)
		else: #else move to the location
			committed = true
			charge_move(old_coords, new_coords, grid)
			
	else:
		move_to(old_coords, old_coords, grid)
	grid.reset_highlighting()
	return committed


func charge_move(old_coords, new_coords, grid, attack=false):
	var difference = new_coords - old_coords
	var increment = grid.hex_normalize(difference)
	var target_coords = new_coords
	
	#if attacking an enemy at the end, charge up to the square before their tile
	if(attack):
		target_coords = new_coords - increment
	
	move_to(old_coords, target_coords, grid)
	yield(self, "animation_finished")
	get_parent().set_coords(target_coords)
	
	var current_coords = old_coords + increment
	
	var tiles_passed = 1
	#deal damage to every tile you passed over
	while(current_coords != target_coords):
		if grid.pieces.has(current_coords) and grid.pieces[current_coords].side == "ENEMY":
			grid.pieces[current_coords].attacked(1)
			
		tiles_passed += 1
		current_coords = current_coords + increment
	print("attack is " + str(attack))
	print(grid.pieces[new_coords])
	if attack and grid.pieces.has(new_coords) and grid.pieces[new_coords].side == "ENEMY":
		print("attacking")
		grid.pieces[new_coords].attacked(tiles_passed)


	
func _is_within_range(old_coords, new_coords, grid):
	var neighbors = grid.get_neighbors(old_coords, [1, 11])
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	

