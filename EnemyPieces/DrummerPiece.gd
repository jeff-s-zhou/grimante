extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "Causes all enemy pieces in the column to move +1 tiles each turn."

func initialize(max_hp):
	set_hp(max_hp)
	self.unit_name = "Shrieker"
	self.hover_description = DESCRIPTION
	self.movement_value = Vector2(0, 2)
	self.default_movement_value = Vector2(0, 2)
	
#okay, I think we need a system for temporary buffs?
#every enemy turn, update all units in its column? after resetting all units? but then this update has to be called first...
#a method call called aura effects? that's looped through before other shit?

func aura_update():
	var column_range = get_parent().get_range(self.coords, [1, 12], "ENEMY", false, [0, 1])
	column_range += get_parent().get_range(self.coords, [1, 12], "ENEMY", false, [3, 4])
	print("in aura update")
	for coords in column_range:
		print("caught an enemy in the aura enemy")
		get_parent().pieces[coords].movement_value += Vector2(0, 1)