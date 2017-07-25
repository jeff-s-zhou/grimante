
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Practice Barrel. Does not move."

func initialize(max_hp, modifiers, prototype):
	.initialize("Barrel", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, self.YELLOW_EXPLOSION_SCENE)


