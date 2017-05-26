extends "res://UI/TextureLabelButton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var star_count = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.y_difference = 7

func add_star():
	self.star_count += 1
	get_node("TextureButton").set_disabled(false)
	get_node("/root/AnimationQueue").enqueue(self, "animate_add_star", false, [self.star_count])
	
func animate_add_star(crystal_count):
	get_node("Toppings/Label").set_text(str(star_count))
	
func is_pressed():
	print("calling is_pressed")
	.is_pressed()
	if self.star_count > 0:
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.activate_finisher()
		self.star_count -= 1
		if self.star_count == 0:
			get_node("TextureButton").set_disabled(true)
		get_node("Toppings/Label").set_text(str(self.star_count))