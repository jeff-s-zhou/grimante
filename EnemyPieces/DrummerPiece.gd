extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "Causes itself and all Enemies ahead of it to move twice each turn."

func initialize(max_hp, modifiers, prototype):
	self.double_time = true
	.initialize("Griffon", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.assist)

func added_to_grid():
	.added_to_grid()
	self.grid.animate_speed_up(self.coords)

#okay, I think we need a system for temporary buffs?
#every enemy turn, update all units in its column? after resetting all units? but then this update has to be called first...
#a method call called aura effects? that's looped through before other shit?

func turn_start():
	if !self.silenced:
		self.double_time = true
		var column_range = self.grid.get_range(coords, [1, 8], "ENEMY", false, [3, 4])
		for coords in column_range:
			self.grid.pieces[coords].double_time = true
	else:
		self.double_time = false
		
func delete_self(isolated_call=true, delay=0.0):
	self.grid.animate_clear_speed_up(self.coords)
	.delete_self(isolated_call, delay)
	
func turn_attack_update():
	if !self.silenced:
		self.grid.animate_speed_up(self.coords)
	.turn_attack_update()