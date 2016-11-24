
extends "PlayerPieceType.gd"
# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/cavalier_piece.png"

var STATES = {"default":0, "moving":1}
var animation_state = STATES.default
var velocity
var new_position

signal animation_finished

const UNIT_TYPE = "Cavalier"
const DESCRIPTION = """Armor: 2
Movement: Rush - Can move to any empty tile along a straight line path.\n
Attack: Joust. Targeting an enemy unit at the end of your Rush deals 1 damage for every tile travelled. Applies Knockback.\n
Passive: Trample. Moving through an enemy unit deals 1 damage to it."""

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)


func move_to(old_coords, new_coords, grid, speed=6):
	var location = grid.locations[new_coords]
	new_position = location.get_pos()
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * speed
	self.animation_state = STATES.moving
	
func animate_attack(attack_coords, grid, speed=6):
	var location = grid.locations[attack_coords]
	new_position = location.get_pos() - ((location.get_pos() - get_parent().get_pos()) / 2)
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * speed
	self.animation_state = STATES.moving
	
func animate_attack_end(original_coords, grid, speed=6):
	var location = grid.locations[original_coords]
	new_position = location.get_pos()
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * speed
	self.animation_state = STATES.moving
	

#parameters to use for get_node("Grid").get_neighbors
func display_action_range(coords, grid):
	var neighbors = grid.get_neighbors(coords, [1, 11])
	for neighbor in neighbors:
		neighbor.movement_highlight()


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

	if _is_within_range(old_coords, new_coords, grid):
		#if there's a piece in the new coord
		if grid.pieces.has(new_coords) \
		and grid.pieces[new_coords].side == "ENEMY":
			if _is_within_range(old_coords, new_coords, grid, [1, 2]): #but it's not adjacent
				return false
			charge_move(old_coords, new_coords, grid, true)
			return true
		else: #else move to the location
			charge_move(old_coords, new_coords, grid)
			return true
	return false


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
		
	if attack and grid.pieces.has(new_coords) and grid.pieces[new_coords].side == "ENEMY":
		animate_attack(new_coords, grid)
		yield(self, "animation_finished")
		grid.pieces[new_coords].attacked(tiles_passed)
		animate_attack_end(target_coords, grid)
	
	placed()
	

	
func _is_within_range(old_coords, new_coords, grid, action_range=[1, 11]):
	var neighbors = grid.get_neighbors(old_coords, action_range)
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	

