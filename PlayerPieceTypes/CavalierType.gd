
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var texture_path = "res://Assets/cavalier_piece.png"

var damage = 2
var aoe_damage = 2
signal invalid_move
var STATES = {"default":0, "moving":1}
var state = STATES.default
var velocity
var new_position

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)

#parameters to use for get_node("Grid").get_neighbors
func display_action_range(coords, grid):
	print("displaying action range")
	var neighbors = grid.get_neighbors(coords, [1, 11])
	for neighbor in neighbors:
		neighbor.movement_highlight()
		
func move(old_coords, new_coords, grid):
	get_parent().set_coords(new_coords)
	var location = grid.locations[new_coords]
	new_position = location.get_pos()
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * 4
	self.state = STATES.moving


func move_animation(delta):
	var old_pos = get_parent().get_pos()
	get_parent().move(velocity) 
	

func _fixed_process(delta):
	if self.state == STATES.moving:
		var difference = (new_position - get_parent().get_pos()).length()
		if (difference < 6.0):
			self.state = STATES.default
			get_parent().set_pos(new_position)
		else:
			move_animation(delta)


func act(old_coords, new_coords, grid):
	#returns whether the act was successfully committed
	var committed = false
	if _is_within_range(old_coords, new_coords, grid):
		if grid.pieces.has(new_coords): #if there's a piece in the new coord
				print("invalid move")
				move(old_coords, old_coords, grid)
				emit_signal("invalid_move")
		else: #else move to the location
			committed = true
			charge_attack(old_coords, new_coords, grid)
			
	else:
		print("invalid_move")
		move(old_coords, old_coords, grid)
		emit_signal("invalid_move")
	
	grid.reset_highlighting()
	return committed
	
func charge_attack(old_coords, new_coords, grid):
	var difference = new_coords - old_coords
	var increment = grid.hex_normalize(difference)
	move(old_coords, new_coords, grid)
	
	var current_coords = old_coords + increment
	
	var tiles_passed = 1
	#deal damage to every tile you passed over
	while(current_coords != new_coords):
		if grid.pieces.has(current_coords) and grid.pieces[current_coords].side == "ENEMY":
			grid.pieces[current_coords].attacked(1)
			
		tiles_passed += 1
		current_coords = current_coords + increment
		
	#deal damage to the tile at the end of your charge, scaling with distance travelled
	var target_coords = new_coords + increment
	if grid.pieces.has(target_coords) and grid.pieces[target_coords].side == "ENEMY":
		grid.pieces[target_coords].attacked(tiles_passed)
	
	
func _is_within_range(old_coords, new_coords, grid):
	var neighbors = grid.get_neighbors(old_coords, [1, 11])
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	

