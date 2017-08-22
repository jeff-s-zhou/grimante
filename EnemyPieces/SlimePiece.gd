extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "While alive, reduces adjacent Heroes movement to 1."

func initialize(max_hp, modifiers, prototype):
	.initialize("Slime", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.attack)
	
func set_cloaked(flag):
	.set_cloaked(flag)  
	if flag:
		get_node("Sludge").set_opacity(0)
	else:
		add_animation(self, "show_sludge", false)
	

#this clever shit might come back to bite me in the ass
#I just needed to slap an animation before and after every move, so we construct the animation_sequence here
func move(distance, passed_animation_sequence=null):
	add_animation(self, "hide_sludge", false)
	.move(distance)
	add_animation(self, "show_sludge", false)
	
	
func delete_self():
	add_animation(self, "hide_sludge", false)
	.delete_self()
	
	
func is_slime():
	if !self.silenced:
		return true

func hide_sludge():
	print("calling hide sludge")
	get_node("Tween").interpolate_property(get_node("Sludge"), "visibility/opacity", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
func show_sludge():
	print("calling show sludge")
	get_node("Tween").interpolate_property(get_node("Sludge"), "visibility/opacity", 0, 1, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()