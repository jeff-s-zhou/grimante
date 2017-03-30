extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "Causes all enemy pieces in the column in front of it (including itself) to move +1 tiles each turn."

func initialize(max_hp, modifiers):
	.initialize("Shrieker", DESCRIPTION, Vector2(0, 2), max_hp, modifiers)

#okay, I think we need a system for temporary buffs?
#every enemy turn, update all units in its column? after resetting all units? but then this update has to be called first...
#a method call called aura effects? that's looped through before other shit?

func aura_update():
	if !self.silenced:
		var column_range = get_parent().get_range(self.coords, [1, 12], "ENEMY", false, [3, 4])
		for coords in column_range:
			get_parent().pieces[coords].movement_value = Vector2(0, 2)
	else:
		self.movement_value = Vector2(0, 1)