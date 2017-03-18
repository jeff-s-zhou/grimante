
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
	if !self.stunned:
		var swipe_range = get_parent().get_range(self.coords, [1, 2], "PLAYER")
		for coords in swipe_range:
			swipe(coords)
	enqueue_animation_sequence()

		
func swipe(coords):
	add_animation(self, "animate_swipe", true, [coords])
	if self.current_animation_sequence != null:
		print("current_animation_sequence not equal to null")
		get_parent().pieces[coords].player_attacked(self, self.current_animation_sequence)
	else:
		get_parent().pieces[coords].player_attacked(self)
	add_animation(self, "animate_swipe_end", true, [self.coords])

func animate_swipe(attack_coords):
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, true, Tween.TRANS_SINE, Tween.EASE_IN)

func animate_swipe_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)