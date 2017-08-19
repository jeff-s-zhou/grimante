
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Basic Boss. Ignores 1 damage attacks. All other attacks deal 1 damage."

func initialize(max_hp, modifiers, prototype):
	.initialize("Pawn Boss", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)
	set_boss(true)