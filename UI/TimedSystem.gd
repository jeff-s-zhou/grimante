extends "ClearRoomSystem.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var num_turns


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(level_schematic):
	self.enemies = level_schematic.enemies
	self.num_turns = level_schematic.num_turns
	self.turns_til_wave = self.enemies.get_turns_til_next_wave(0)
	get_node("TurnCountdown").set_text(str(self.num_turns))
	if self.turns_til_wave != null:
		get_node("WaveCountdown").set_text(str(self.turns_til_wave))

func update(turn_count):
	self.turns_til_wave = self.enemies.get_turns_til_next_wave(turn_count)
	get_node("TurnCountdown").set_text(str(self.num_turns - turn_count))
	if self.turns_til_wave != null:
		get_node("WaveCountdown").set_text(str(self.turns_til_wave))
		
		
func check_enemy_win(turn_count): #only checks part of the condition. other is in the game loop
	return get_tree().get_nodes_in_group("player_pieces").size() == 0 or self.num_turns - turn_count == 0