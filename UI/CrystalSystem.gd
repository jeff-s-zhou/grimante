extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var crystals = []

var crystal_texture = preload("res://Assets/effects/combo_sparkle_cross_blue.png")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)	

func add_crystal():
	var crystal = Sprite.new()
	crystal.set_texture(self.crystal_texture)
	self.crystals.append(crystal)
	
	crystal.set_pos(Vector2(30 * self.crystals.size(), 0))
	add_child(crystal)
	
func consume_crystals():
	for i in range(1, 4):
		self.crystals[self.crystals.size() - 1].queue_free()
	

func _input(event):
	if event.is_action("test_action3") and event.is_pressed() and self.crystals.size() > 3:
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.reactivate()
			consume_crystals()
	