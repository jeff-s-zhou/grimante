extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "When this enemy dies, +1 hp to adjacent enemies."

func initialize(max_hp):
	set_hp(max_hp)
	self.unit_name = "Seraph"
	self.hover_description = DESCRIPTION
	self.movement_value = Vector2(0, 1)
	self.default_movement_value = Vector2(0, 1)
	#self.set_shield(true)
	
func delete_self():
	.delete_self()
	var neighbor_coords_range = get_parent().get_range(self.coords, [1,2], "ENEMY")
	for coords in neighbor_coords_range:
		var neighbor = get_parent().pieces[coords]
		neighbor.heal(1)
	