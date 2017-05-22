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
	self.turns_til_wave = self.enemies.get_turns_til_next_wave(0)
	if self.turns_til_wave == null:
		get_node("Label").set_text("Clear the Board")
	else:
		get_node("Label").set_text("Clear the Board" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")


func update(turn_count):
		self.turns_til_wave = self.enemies.get_turns_til_next_wave(turn_count)
		
		if self.turns_til_wave == null:
				get_node("Label").set_text("Clear the Board")
		else:
			get_node("Label").set_text("Clear the Board" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")


func check_player_win():
	return get_tree().get_nodes_in_group("enemy_pieces").size() == 0

		
func check_enemy_win(): #only checks part of the condition. other is in the game loop
	return get_tree().get_nodes_in_group("player_pieces").size() == 0