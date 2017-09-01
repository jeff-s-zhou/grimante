extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var num_turns
var flags
var enemies = null
var turns_til_wave = 0
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(level_schematic, star_button_handle, flags):
	
	print("initializing in timed system")
	
	self.num_turns = 0
	self.turns_til_wave = 0
	self.flags = flags
	
	if flags.has("no_stars"):
		get_node("KillsHeader").hide()
		get_node("StarSubsystem").hide()
	else:
		get_node("StarSubsystem").connect("add_star", star_button_handle, "add_star")
	
	
	self.enemies = level_schematic.enemies
	if !flags.has("no_turns"):
		self.num_turns = level_schematic.num_turns
	self.turns_til_wave = self.enemies.get_turns_til_next_wave(0)
	
	if flags.has("no_turns"):
		get_node("TurnsHeader").hide()
		get_node("TurnCountdown").hide()
	else:
		get_node("Label").hide()
		get_node("TurnCountdown").set_text(str(1) + "/" + str(self.num_turns))
		
	if flags.has("no_waves"):
		get_node("WaveHeader").hide()
		get_node("WaveCountdown").hide()
	else:
		#after the tutorial with reinforcements, we hide the message
		get_node("Label").hide()
		if self.turns_til_wave != null:
			get_node("WaveCountdown").set_text(str(self.turns_til_wave - 1))


func soft_reset(level_schematic):
	self.num_turns = 0
	self.turns_til_wave = 0
	self.flags = flags
	get_node("StarSubsystem").reset()
	self.enemies = level_schematic.enemies
	update(0)

func update(turn_count):
	print("updating in timed system")
	if !self.flags.has("no_turns"):
		get_node("TurnCountdown").set_text(str(turn_count + 1) + "/" + str(self.num_turns))
	
	if !self.flags.has("no_waves"):
		self.turns_til_wave = self.enemies.get_turns_til_next_wave(turn_count)
		if self.turns_til_wave != null:
			get_node("WaveCountdown").set_text(str(self.turns_til_wave - 1))
		else:
			get_node("WaveCountdown").set_text("-")

		
func check_enemy_win(turn_count): #only checks part of the condition. other is in the game loop	
	if self.flags.has("no_turns"):
		return get_tree().get_nodes_in_group("player_pieces").size() == 0
	else:
		return get_tree().get_nodes_in_group("player_pieces").size() == 0 or self.num_turns - turn_count == 0
		

func check_player_win():
	return get_tree().get_nodes_in_group("enemy_pieces").size() == 0