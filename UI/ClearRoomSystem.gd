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
	
func initialize(enemies):
	self.enemies = enemies
	self.turns_til_wave = self.enemies.get_turns_til_next_wave()
	if self.turns_til_wave == null:
		get_node("Label").set_text("Clear the Board")
	else:
		get_node("Label").set_text("Clear the Board" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")

func update():
	if self.turns_til_wave != null:
		if self.turns_til_wave == 0:
			self.turns_til_wave = self.enemies.get_turns_til_next_wave()
		else:
			self.turns_til_wave -= 1
			
		if self.turns_til_wave == null:
				get_node("Label").set_text("Clear the Board")
		else:
			get_node("Label").set_text("Clear the Board" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")