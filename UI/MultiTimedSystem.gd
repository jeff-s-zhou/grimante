extends "ClearRoomSystem.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(level_schematic):
	self.enemies = level_schematic.enemies
	self.turns_til_wave = self.enemies.get_turns_til_next_wave()
	if self.turns_til_wave == null:
		get_node("Label").set_text("Phased Clear: Win in " + str(self.turns_left) + " Turns")
	else:
		get_node("Label").set_text("Phased Clear: Clear the board in " +  str(self.turns_til_wave) + " turns")


func pre_deploy_wave_check():
	self.enemies.phase_skip()
	get_parent().get_node("Grid").reset_deploy_indicators()
	
	
func update():
	self.turns_til_wave = self.enemies.get_turns_til_next_wave()
	
	
	if self.turns_til_wave == null:
		get_node("Label").set_text("Timed Clear: Win in " + str(self.turns_left) + " Turns")
	else:	
		get_node("Label").set_text("Timed Clear: Win in " + str(self.turns_left) + " Turns" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")
		
		
func check_enemy_win(): #only checks part of the condition. other is in the game loop
	return get_tree().get_nodes_in_group("player_pieces").size() == 0 or self.turns_left == 0
	
func check_player_win():
	self.enemies.is_last_phase() and get_tree().get_nodes_in_group("enemy_pieces").size() == 0