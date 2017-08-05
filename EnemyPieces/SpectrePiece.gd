extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Cannot be Direct Attacked."

func initialize(max_hp, modifiers, prototype):
	.initialize("Spectre", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)