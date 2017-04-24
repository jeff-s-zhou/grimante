extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var enemies = null

var turns_til_wave = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(level_schematic):
	self.enemies = level_schematic.enemies
	get_node("ReinforcementDisplay").display_waves(self.enemies.turn_power_levels, self.enemies.big_wave_threshold)
	get_node("ReinforcementDisplay").set_pos(Vector2(-150, 25))
	self.turns_til_wave = self.enemies.get_turns_til_next_wave()
	if self.turns_til_wave == null:
		get_node("Label").set_text("Clear the Board")
	else:
		get_node("Label").set_text("Clear the Board" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")


func update_reinforcement_display():
	get_node("ReinforcementDisplay").update_waves()

func update():
		self.turns_til_wave = self.enemies.get_turns_til_next_wave()
		
		if self.turns_til_wave == null:
				get_node("Label").set_text("Clear the Board")
		else:
			get_node("Label").set_text("Clear the Board" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")


func check_player_win():
	return get_tree().get_nodes_in_group("enemy_pieces").size() == 0

		
func check_enemy_win(): #only checks part of the condition. other is in the game loop
	return get_tree().get_nodes_in_group("player_pieces").size() == 0