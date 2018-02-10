extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Cannot be Direct Attacked."

func initialize(max_hp, modifiers, prototype):
	.initialize("Spectre", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)
	get_node("CollisionArea").disconnect("mouse_enter", self, "hovered")
	get_node("CollisionArea").disconnect("mouse_exit", self, "unhovered")
	

func input_event(event, has_selected):
	print("in spectre input event")
	if !self.silenced:
		if event.is_pressed():
			get_node("/root/Combat").display_description(self)
	else:
		.input_event(event, has_selected)
		
		
func set_silenced(flag):
	if flag:
		get_node("CollisionArea").connect("mouse_enter", self, "hovered")
		get_node("CollisionArea").connect("mouse_exit", self, "unhovered")
	.set_silenced(flag)

	
func show_red():
	if self.silenced:
		.show_red()