
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Basic Enemy. Moves forward 1 tile each turn."

func initialize(max_hp, modifiers, prototype):
	.initialize("Pawn", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype)


