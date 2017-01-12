extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "This enemy gains +1 hp each turn."

func initialize(max_hp):
	initialize_hp(max_hp)
	self.unit_name = "Absorber"
	self.hover_description = DESCRIPTION
	self.movement_value = Vector2(0, 1)
	self.default_movement_value = Vector2(0, 1)
	
#	
#	
func turn_update():
	heal(1)
	.turn_update()