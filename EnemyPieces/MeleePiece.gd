
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "After moving, attacks all nearby Player Units. If its health is greater than or equal to the Player Units shield, it is KOed."

func initialize(max_hp, modifiers):
	.initialize("Werewolf", DESCRIPTION, Vector2(0, 1), max_hp, modifiers)


func turn_update():
	turn_update_helper()
	if !self.stunned and !self.silenced:
		var swipe_range = get_parent().get_range(self.coords, [1, 2], "PLAYER")
		for coords in swipe_range:
			swipe(coords)
	enqueue_animation_sequence()

		
func swipe(coords):
	start_swipe(coords)
	if self.current_animation_sequence != null:
		print("current_animation_sequence not equal to null")
		get_parent().pieces[coords].player_attacked(self, self.current_animation_sequence)
	else:
		get_parent().pieces[coords].player_attacked(self)
	end_swipe()

func start_swipe(attack_coords):
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	add_animation(self, "animate_move_to_pos", true, [new_position, 450, true])

func end_swipe():
	var location = get_parent().locations[self.coords]
	var new_position = location.get_pos()
	add_animation(self, "animate_move_to_pos", true, [new_position, 300, true])