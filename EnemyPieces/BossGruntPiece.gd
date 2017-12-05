
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Basic Boss. Ignores 1 damage attacks. All other attacks deal 1 damage. Cannot be Silenced."

func initialize(max_hp, modifiers, prototype):
	.initialize("Pawn Boss", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)
	set_boss(true)
	add_to_group("boss_pieces")
	
func delete_self(delay, blocking):
	.delete_self(delay, blocking)
	remove_from_group("boss_pieces")
	get_node("/root/Combat").handle_boss_death()
	
func smashed(attacker):
	set_shield(false)
	return false