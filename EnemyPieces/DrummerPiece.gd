extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "Causes itself and all Enemies ahead of it to move twice each turn."

func initialize(max_hp, modifiers, prototype):
	self.double_time = true
	.initialize("Griffon", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.assist)

func added_to_grid():
	animate_wind()
	.added_to_grid()

#okay, I think we need a system for temporary buffs?
#every enemy turn, update all units in its column? after resetting all units? but then this update has to be called first...
#a method call called aura effects? that's looped through before other shit?

func turn_start():
	if !self.silenced:
		var column_range = get_parent().get_range(self.coords, [1, 8], "ENEMY", false, [3, 4])
		for coords in column_range:
			get_parent().pieces[coords].double_time = true
	else:
		self.double_time = false
		
func animate_wind():
	get_parent().get_node("FieldEffects").emit_wind(self.coords)
	get_node("Tween 3").interpolate_callback(self, 5.1, "animate_wind")
	get_node("Tween 3").start()