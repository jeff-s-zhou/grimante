extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "When this enemy dies, +2 hp to adjacent enemies."

func initialize(max_hp, modifiers, prototype):
	.initialize("Seraph", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype)

func deathrattle():
	if !self.silenced and self.hp == 0:
		var neighbor_coords_range = get_parent().get_range(self.coords, [1,2], "ENEMY")
		for coords in neighbor_coords_range:
			var neighbor = get_parent().pieces[coords]
			neighbor.heal(2, 1.5) #delay it by 1.5 so it happens when this piece dies
	