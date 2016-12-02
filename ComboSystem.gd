
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var combo_chain = 0
var combo_points = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ComboPointsLabel").set_text(str(combo_points))
	
func player_turn_ended():
	combo_chain = 0
	get_node("ComboPointsLabel").set_text(str(combo_points))

func increase_combo():
	combo_chain += 1
	combo_points += (100 * pow(2, combo_chain))
	get_node("ComboPointsLabel").set_text(str(combo_points))

