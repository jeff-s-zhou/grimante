
extends "RangedPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var OVERRIDE_DESCRIPTION = "Ignores 1 damage attacks. All other attacks deal 1 damage. Kill all bosses to beat the level. Before moving, shoots a Fireball downwards if not blocked by other Enemies. The Fireball functions the same as a regular Enemy Attack."
var OVERRIDE_NAME = "Fire Drake Boss"

func initialize(max_hp, modifiers, prototype):
	self.DESCRIPTION = OVERRIDE_DESCRIPTION
	self.NAME = OVERRIDE_NAME
	.initialize(max_hp, modifiers, prototype)
	set_boss(true)
	add_to_group("boss_pieces")
	
func delete_self(delay, blocking):
	.delete_self(delay, blocking)
	remove_from_group("boss_pieces")
	get_node("/root/Combat").handle_boss_death()
	
func smashed(attacker):
	set_shield(false)
	return false

	