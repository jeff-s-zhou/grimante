extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "Causes all enemy pieces in the column (including itself) to move +1 tiles each turn."

func initialize(max_hp, modifiers, prototype):
	.initialize("Griffon", DESCRIPTION, Vector2(0, 2), max_hp, modifiers, prototype)
	animate_wind()

#okay, I think we need a system for temporary buffs?
#every enemy turn, update all units in its column? after resetting all units? but then this update has to be called first...
#a method call called aura effects? that's looped through before other shit?

func aura_update():
	if !self.silenced:
		var column_range = get_parent().get_range(self.coords, [1, 9], "ENEMY", false, [3, 4])
		column_range += get_parent().get_range(self.coords, [1, 9], "ENEMY", false, [0, 1])
		for coords in column_range:
			get_parent().pieces[coords].movement_value = Vector2(0, 2)
	else:
		self.movement_value = Vector2(0, 1)
		
func animate_wind():
	get_parent().get_node("FieldEffects").emit_wind(self.coords)
	get_node("Tween 3").interpolate_callback(self, 5.1, "animate_wind")
	get_node("Tween 3").start()