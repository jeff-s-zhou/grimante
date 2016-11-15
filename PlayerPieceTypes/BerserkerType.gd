
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var texture_path = "res://Assets/berserker_piece.png"

var damage = 2
var aoe_damage = 2
signal invalid_move

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#parameters to use for get_node("Grid").get_neighbors
func display_action_range(coords, grid):
	print("displaying action range")
	var neighbors = grid.get_radial_neighbors(coords)
	for neighbor in neighbors:
		neighbor.movement_highlight()
		
func move(old_coords, new_coords, grid):
	get_parent().set_coords(new_coords)
	var location = grid.locations[new_coords]
	get_parent().set_pos(location.get_pos())


func act(old_coords, new_coords, grid):
	#returns whether the act was successfully committed
	var committed = false
	if _is_within_range(old_coords, new_coords, grid):
		if grid.pieces.has(new_coords): #if there's a piece in the new coord
			if grid.pieces[new_coords].side == "ENEMY":
				committed = true
				grid.pieces[new_coords].attacked(self.damage)
				smash_attack(old_coords, new_coords, grid)
			else:
				print("invalid move")
				move(old_coords, old_coords, grid)
				emit_signal("invalid_move")
				
		else: #else move to the location
			committed = true
			smash_attack(old_coords, new_coords, grid)
			
	else:
		print("invalid_move")
		move(old_coords, old_coords, grid)
		emit_signal("invalid_move")
	
	grid.reset_highlighting()
	return committed
	
func smash_attack(old_coords, new_coords, grid):
	var neighbors = []
	
	#check if we killed the unit, if so, move there
	if !grid.pieces.has(new_coords):
		move(old_coords, new_coords, grid)
		neighbors = grid.get_neighbors(new_coords)
	else:
		move(old_coords, old_coords, grid)
		neighbors = grid.get_neighbors(old_coords)
	
	#deal aoe damage to wherever you land
	for neighbor in neighbors:
		if neighbor.has_method("attacked"):
			neighbor.attacked(self.aoe_damage)


func _is_within_range(old_coords, new_coords, grid):
	var neighbors = grid.get_radial_neighbors(old_coords)
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	



