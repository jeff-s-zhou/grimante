extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Cannot be damaged for any amount higher than its current Power."

func initialize(max_hp, modifiers, prototype):
	.initialize("Spectre", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, self.YELLOW_EXPLOSION_SCENE)


func attacked(amount, delay=0.0, interrupting=true):
	if amount > self.hp:
		amount = 0
	.attacked(amount, delay, interrupting)
	
func get_actual_damage(damage):
	if self.shielded:
		return 0
	elif damage > self.hp:
		return 0
	else:
		return damage