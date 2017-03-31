extends "ClearRoomSystem.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var turns_left = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(level_schematic):
	self.turns_left = level_schematic.num_turns
	self.enemies = level_schematic.enemies
	self.turns_til_wave = self.enemies.get_turns_til_next_wave() 
	if self.turns_til_wave == null:
		get_node("Label").set_text("Hold the Line: " + str(self.turns_left) + " Turns Remaining")
	else:
		get_node("Label").set_text("Hold the Line: " + str(self.turns_left) + " Turns Remaining" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")

func update():
	self.turns_til_wave = self.enemies.get_turns_til_next_wave()

	if self.turns_til_wave == null:
		get_node("Label").set_text("Hold the Line: " + str(self.turns_left) + " Turns Remaining")
	else:	
		get_node("Label").set_text("Hold the Line: " + str(self.turns_left) + " Turns Remaining" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")
		
		
func check_player_win():
	return get_tree().get_nodes_in_group("enemy_pieces").size() == 0 or self.turns_left == 0