extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Cannot be Direct Attacked."

func initialize(max_hp, modifiers, prototype):
	.initialize("Spectre", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)
	
	
#when another unit is able to move to this location, it calls this function
func movement_highlight():
	if !self.deploying_flag:
		self.action_highlighted = true