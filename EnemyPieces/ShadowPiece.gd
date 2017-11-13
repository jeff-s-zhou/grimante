extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Only the original Hero deals full damage. Receives 1 damage from attacks by all other Heroes."

func initialize(max_hp, modifiers, prototype):
	.initialize("Shadow", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)
	

#going to need to get the caller of the attack fuuuuck
func get_actual_damage(damage):
	var tile = get_parent().locations[coords]
	
	#TODO put this through an action call
	
	if self.boss_flag:
		if damage > 1:
			damage = 1
		else:
			damage = 0

	if self.shielded:
		return 0
	else:
		return damage
	
