
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "After moving, attacks all adjacent Heroes. If its Power is greater than or equal to the Hero's Armor, the Hero is KOed."

func initialize(max_hp, modifiers, prototype):
	.initialize("Werewolf", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.attack)


func turn_update_helper():
	if !self.stunned and self.hp != 0:
		self.move(movement_value)

func turn_attack_update():
	if self.hp != 0 and !self.silenced and !self.stunned:
		var swipe_range = get_parent().get_range(self.coords, [1, 2], "PLAYER")
		for coords in swipe_range:
			swipe(coords)
	.turn_attack_update()
	

		
func swipe(coords):
	add_animation(self, "start_swipe", true, [coords])
	get_parent().pieces[coords].attacked(self)
	add_animation(self, "end_swipe", true)

func start_swipe(attack_coords):
	var location = get_parent().locations[attack_coords]
	var location_of_attack = 3
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, true)

func end_swipe():
	var location = get_parent().locations[self.coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)