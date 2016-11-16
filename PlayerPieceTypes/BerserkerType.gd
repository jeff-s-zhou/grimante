
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/berserker_piece.png"

const DAMAGE = 2
const AOE_DAMAGE = 2

const STATES = {"default":0, "jumping":1, "moving":2, "landing":3}

var animation_state = STATES.default
var velocity
var jump_up_position
var jump_down_position
var new_position

const JUMP_HEIGHT = Vector2(0, -40)
const JUMP_VELOCITY = Vector2(0, -2)
const LAND_VELOCITY = Vector2(0, 8)

signal animation_finished

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)

#parameters to use for get_node("Grid").get_neighbors
func display_action_range(coords, grid):
	var neighbors = grid.get_radial_neighbors(coords)
	for neighbor in neighbors:
		neighbor.movement_highlight()
	
func move_to(old_coords, new_coords, grid):
	var location = grid.locations[new_coords]
	jump_up_position = get_parent().get_pos() + JUMP_HEIGHT
	new_position = location.get_pos()
	jump_down_position = new_position + JUMP_HEIGHT
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * 4
	self.animation_state = STATES.jumping
	
	
func _fixed_process(delta):
	if self.animation_state == STATES.jumping:
		var difference = (jump_up_position -  get_parent().get_pos()).length()
		if (difference < 3.0):
			self.animation_state = STATES.moving
			get_parent().set_pos(jump_up_position)
		else:
			get_parent().move(JUMP_VELOCITY)
	
	if self.animation_state == STATES.moving:
		var difference = (jump_down_position - get_parent().get_pos()).length()
		if (difference < 6.0):
			self.animation_state = STATES.landing
			get_parent().set_pos(jump_down_position)
		else:
			get_parent().move(velocity) 
			
	if self.animation_state == STATES.landing:
		var difference = (new_position - get_parent().get_pos()).length()
		if (difference < 3.0):
			self.animation_state = STATES.default
			get_parent().set_pos(new_position)
			emit_signal("animation_finished")
		else:
			get_parent().move(LAND_VELOCITY)


func act(old_coords, new_coords, grid):
	#returns whether the act was successfully committed
	var committed = false
	if _is_within_range(old_coords, new_coords, grid):
		if grid.pieces.has(new_coords): #if there's a piece in the new coord
			if grid.pieces[new_coords].side == "ENEMY":
				committed = true
				grid.pieces[new_coords].attacked(DAMAGE)
				smash_attack(old_coords, new_coords, grid)
			else:
				move_to(old_coords, old_coords, grid)

		else: #else move to the location
			committed = true
			smash_attack(old_coords, new_coords, grid)
			
	else:
		move_to(old_coords, old_coords, grid)

	grid.reset_highlighting()
	return committed
	
func smash_attack(old_coords, new_coords, grid):
	var neighbors = []
	
	
	#check if we killed the unit, if so, move there
	if !grid.pieces.has(new_coords):
		move_to(old_coords, new_coords, grid)
		neighbors = grid.get_neighbors(new_coords)
		get_parent().set_coords(new_coords)
	else:
		move_to(old_coords, old_coords, grid)
		neighbors = grid.get_neighbors(old_coords)
	
	#deal aoe damage to wherever you land
	for neighbor in neighbors:
		if neighbor.has_method("attacked"):
			neighbor.attacked(AOE_DAMAGE)


func _is_within_range(old_coords, new_coords, grid):
	var neighbors = grid.get_radial_neighbors(old_coords)
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	



