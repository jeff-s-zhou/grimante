extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"



var crystal_count = 0


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)	
	get_node("TextureButton").connect("pressed", self, "consume_crystal")
	
#func update(turn_count):
#	if turn_count + 1 % 3 == 0:
#		add_crystal()
	

	

func add_crystal():
	self.crystal_count += 1
	get_node("TextureButton").set_disabled(false)
	get_node("/root/AnimationQueue").enqueue(self, "animate_add_crystal", false, [self.crystal_count])
	
func animate_add_crystal(crystal_count):
	get_node("Label").set_text(str(crystal_count))


func consume_crystal():
	if self.crystal_count > 0:
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.activate_finisher()
		self.crystal_count -= 1
		if self.crystal_count == 0:
			get_node("TextureButton").set_disabled(true)
		get_node("Label").set_text(str(self.crystal_count))