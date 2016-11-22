
extends "PlayerPieceType.gd"

# member variables here, example:
# var a=2
# var b="textvar"

const texture_path = "res://Assets/berserker_piece.png"

const DAMAGE = 3
const AOE_DAMAGE = 2

const STATES = {"default":0, "moving":1, "jumping":2}

var animation_state = STATES.default
var velocity
var new_position

const UNIT_TYPE = "Berserker"

const DESCRIPTION = """Armor: 2\n
Movement: 2 range leap\n
Attack: Leap Strike. Leap to a tile within movement range. If there is an enemy on the tile, deal 3 damage. If the enemy is not killed by the attack, return to your original tile. Otherwise, move to the tile.\n
Passive: Ground Slam. Moving to a tile deals 2 damage in a 1-range AoE around your destination. Will KO light armor allies."""

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


func move_to(old_coords, new_coords, grid, speed=4):
	var location = grid.locations[new_coords]
	new_position = location.get_pos()
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * speed
	self.animation_state = STATES.moving


func jump_to(old_coords, new_coords, grid):
	var location = grid.locations[new_coords]
	new_position = location.get_pos()
	velocity = (location.get_pos() - get_parent().get_pos()).normalized() * 4
	get_node("AnimationPlayer").play("jump")
	yield( get_node("AnimationPlayer"), "finished" )
	self.animation_state = STATES.jumping
	
	
func _fixed_process(delta):
	if self.animation_state == STATES.moving:
		var difference = (new_position - get_parent().get_pos()).length()
		if (difference < 3.0):
			self.animation_state = STATES.default
			get_parent().set_pos(new_position)
			emit_signal("animation_finished")
		else:
			get_parent().move(velocity)
			
	if self.animation_state == STATES.jumping:
		var difference = (new_position - get_parent().get_pos()).length()
		get_node("AnimationPlayer").play("float")
		if (difference < 3.0):
			get_node("AnimationPlayer").play("smash")
			self.animation_state = STATES.default
			get_parent().set_pos(new_position)
			emit_signal("animation_finished")
		else:
			get_parent().move(velocity)


func act(old_coords, new_coords, grid):
	#returns whether the act was successfully committed
	var committed = false
	
	#if the unit doesn't actually move
	if old_coords == new_coords:
		return committed
	
	if _is_within_range(old_coords, new_coords, grid):
		if grid.pieces.has(new_coords): #if there's a piece in the new coord
			if grid.pieces[new_coords].side == "ENEMY":
				committed = true
				smash_attack(old_coords, new_coords, grid)

		else: #else move to the location
			committed = true
			smash_move(old_coords, new_coords, grid)

	grid.reset_highlighting()
	return committed


func smash_attack(old_coords, new_coords, grid):
	if grid.pieces[new_coords].hp - DAMAGE <= 0:
		jump_to(old_coords, new_coords, grid)
		yield(self, "animation_finished")
		grid.pieces[new_coords].attacked(DAMAGE)
		var neighbors = grid.get_neighbors(new_coords)
		smash(neighbors)
		get_parent().set_coords(new_coords)
		placed()
		
	#else leap back
	else:
		jump_to(old_coords, new_coords, grid)
		yield(self, "animation_finished")
		grid.pieces[new_coords].attacked(DAMAGE)
		jump_to(new_coords, old_coords, grid)
		yield(self, "animation_finished")
		placed()


func smash_move(old_coords, new_coords, grid):
	jump_to(old_coords, new_coords, grid)
	yield(self, "animation_finished")
	var neighbors = grid.get_neighbors(new_coords)
	smash(neighbors)
	get_parent().set_coords(new_coords)
	placed()


func smash(neighbors):
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
	



