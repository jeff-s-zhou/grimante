
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Cannot attack Heroes. Moves up to 3 tiles at a time to the furthest empty tile."

func initialize(max_hp, modifiers, prototype):
	.initialize("Dart Bat", DESCRIPTION, Vector2(0, 3), max_hp, modifiers, prototype, TYPES.selfish)

func move_attack(distance):
	#leap the respective distance. If it kills, move to the tile. If it doesn't, leap back.
	
	var new_coords = self.coords + distance
	for i in range(0, 3):
		#successfully walked off
		if !get_parent().locations.has(new_coords):
			walk_off(distance)
			
		#isn't blocked
		elif !get_parent().pieces.has(new_coords):
			add_animation(self, "animate_move_and_hop", false, [new_coords, 450, false])
			set_coords(new_coords)
			break #end the loop

		new_coords = new_coords - Vector2(0, 1)