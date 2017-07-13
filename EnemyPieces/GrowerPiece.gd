extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "Gains +1 Power at the start of every Enemy Turn."

func initialize(max_hp, modifiers, prototype):
	.initialize("Writher", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, self.YELLOW_EXPLOSION_SCENE)
#	

func turn_update():
	if !self.silenced:
		heal(1)
	.turn_update()