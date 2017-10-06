extends "SpectrePiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"


var DESCRIPTION2 = "Ghost Boss. Cannot be Direct Attacked. Ignores 1 damage attacks. All other attacks deal 1 damage. Cannot be Silenced."

func initialize(max_hp, modifiers, prototype):
	set_boss(true)
	add_to_group("boss_pieces")
	.initialize("Spectre", DESCRIPTION2, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)
	
func delete_self():
	.delete_self()
	remove_from_group("boss_pieces")
	get_node("/root/Combat").handle_boss_death()
	
func smashed(attacker):
	set_shield(false)
	return false