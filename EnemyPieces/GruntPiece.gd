
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Basic Enemy. Moves forward 1 tile each turn."

func initialize(max_hp):
	set_hp(max_hp)
	#set_deadly(true)
	self.unit_name = "Sp00ky Gh0st"
	self.hover_description = DESCRIPTION
	self.movement_value = Vector2(0, 1)
	self.default_movement_value = Vector2(0, 1)


