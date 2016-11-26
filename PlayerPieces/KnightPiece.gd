
extends "PlayerPiece.gd"
# member variables here, example:
# var a=2
# var b="textvar"

var ANIMATION_STATES = {"default":0, "moving":1}
var animation_state = ANIMATION_STATES.default

const UNIT_TYPE = "Knight"
const DESCRIPTION = """Armor: 2
Movement: Rush - Can move to any empty tile along a straight line path.\n
Attack: Joust. Targeting an enemy unit at the end of your Rush deals 1 damage for every tile travelled. Applies Knockback.\n
Passive: Trample. Moving through an enemy unit deals 1 damage to it."""

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	get_node("ClickArea").set_monitorable(false)
	set_process_input(true)


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var neighbors = get_parent().get_neighbors(self.coords, [1, 2])
	for neighbor in neighbors:
		neighbor.movement_highlight()


func act(new_coords):
	if _is_within_range(new_coords):
		if get_parent().pieces.has(new_coords): #if there's a piece in the new coord
			shove(new_coords)
			placed()
			return true
		else: #else move to the location
			animate_move(new_coords, 150)
			yield(get_node("Tween"), "tween_complete")
			set_coords(new_coords)
			placed()
			return true
	return false


func shove(new_coords):
	var difference = new_coords - self.coords
	var increment = get_parent().hex_normalize(difference)
	animate_move(new_coords)
	get_parent().pieces[new_coords].push(increment)
	yield(get_node("Tween"), "tween_complete")
	set_coords(new_coords)

	
func _is_within_range(new_coords):
	var neighbors = get_parent().get_neighbors(self.coords, [1, 2])
	var neighbor_coords = []
	for neighbor in neighbors:
		neighbor_coords.append(neighbor.coords)
	if new_coords in neighbor_coords:
		return true
	else:
		return false
	

