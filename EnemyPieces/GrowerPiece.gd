extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "This enemy gains +1 hp each turn."

func initialize(max_hp, modifiers):
	.initialize("Absorber", DESCRIPTION, Vector2(0, 1), max_hp, modifiers)
#	

func turn_update():
	if !self.silenced:
		heal(1)
	.turn_update()