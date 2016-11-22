
extends "PlayerPieceType.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var STATES = {"default":0, "moving":1}
var animation_state = STATES.default
var velocity
var new_position

signal animation_finished

const UNIT_TYPE = "Knight"
const DESCRIPTION = """Armor: 2
Movement: Rush - Can move to any empty tile along a straight line path.\n
Attack: Joust. Targeting an enemy unit at the end of your Rush deals 1 damage for every tile travelled. Applies Knockback.\n
Passive: Trample. Moving through an enemy unit deals 1 damage to it."""

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)


func move_to(old_coords, new_coords, grid, speed = 2):
	var location = grid.locations[new_coords]
	new_position = location.get_pos()
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * speed
	self.animation_state = STATES.moving


#parameters to use for get_node("Grid").get_neighbors
func display_action_range(coords, grid):
	var neighbors = grid.get_neighbors(coords, [1, 2])
	for neighbor in neighbors:
		neighbor.movement_highlight()


func _fixed_process(delta):
	if self.animation_state == STATES.moving:
		var difference = (new_position - get_parent().get_pos()).length()
		if (difference < 4.0):
			self.animation_state = STATES.default
			get_parent().set_pos(new_position)
			emit_signal("animation_finished")
		else:
			get_parent().move(velocity) 


func act(old_coords, new_coords, grid):
	#returns whether the act was successfully committed
	var committed = false
	
	if old_coords == new_coords:
		return committed
	
	if _is_within_range(old_coords, new_coords, grid):
		if grid.pieces.has(new_coords): #if there's a piece in the new coord
			shove(old_coords, new_coords, grid)
			committed = true
			placed()
		else: #else move to the location
			move_to(old_coords, new_coords, grid)
			yield(self, "animation_finished")
			get_parent().set_coords(new_coords)
			committed = true
			placed()
			
	grid.reset_highlighting()
	return committed
	
func shove(old_coords, new_coords, grid):
	var difference = new_coords - old_coords
	var increment = grid.hex_normalize(difference)
	move_to(old_coords, new_coords, grid)
	grid.pieces[new_coords].push(increment)
	yield(self, "animation_finished")
	get_parent().set_coords(new_coords)
	
	
	
func _is_within_range(old_coords, new_coords, grid):
	var neighbors = grid.get_neighbors(old_coords, [1, 2])
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	

