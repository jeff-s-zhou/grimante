
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "After moving, attacks all nearby Player Units. If its health is greater than or equal to the Player Units shield, The Player is KOed."

func initialize(max_hp, modifiers, prototype):
	.initialize("Werewolf", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype)


func turn_update_helper():
	if !self.stunned and self.hp != 0:
		self.move(movement_value)

func turn_attack_update():
	if self.frozen:
		set_frozen(false)
	
	if self.stunned:
		set_stunned(false)
	elif self.hp != 0 and !self.silenced:
#		if self.current_animation_sequence == null:
#			get_new_animation_sequence()
		var swipe_range = get_parent().get_range(self.coords, [1, 2], "PLAYER")
		for coords in swipe_range:
			swipe(coords)
#		enqueue_animation_sequence()
	handle_rain()
	handle_shifting_sands()
	

		
func swipe(coords):
	add_animation(self, "start_swipe", true, [coords])
	get_parent().pieces[coords].player_attacked(self)
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