extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"


var DESCRIPTION2 = "Cannot be Direct Attacked. Ignores 1 damage attacks. All other attacks deal 1 damage. Kill all Bosses to beat the level."

func initialize(max_hp, modifiers, prototype):
	set_boss(true)
	add_to_group("boss_pieces")
	.initialize("Spectre", DESCRIPTION2, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)

func show_red():
	if self.silenced:
		.show_red()

func delete_self(delay, blocking):
	.delete_self(delay, blocking)
	remove_from_group("boss_pieces")
	get_node("/root/Combat").handle_boss_death()
	
func smashed(attacker):
	set_shield(false)
	return false