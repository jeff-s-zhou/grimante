
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
	
func initialize(max_hp):
	set_hp(max_hp)
	self.movement_value = Vector2(0, 1)


