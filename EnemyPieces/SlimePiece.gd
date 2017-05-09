extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Slime Piece"

func initialize(max_hp, modifiers, prototype):
	.initialize("Slime", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype)

#this clever shit might come back to bite me in the ass
#I just needed to slap an animation before and after every move, so we construct the animation_sequence here
func move(distance, passed_animation_sequence=null):
	var animation_sequence
	if passed_animation_sequence != null:
		animation_sequence = passed_animation_sequence
	else:
		animation_sequence = get_new_animation_sequence()
		
	animation_sequence.add(self, "hide_sludge", false)
	.move(distance, animation_sequence)
	animation_sequence.add(self, "show_sludge", false)

func hide_sludge():
	print("calling hide sludge")
	get_node("Tween").interpolate_property(get_node("Sludge"), "visibility/opacity", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
func show_sludge():
	print("calling show sludge")
	get_node("Tween").interpolate_property(get_node("Sludge"), "visibility/opacity", 0, 1, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()