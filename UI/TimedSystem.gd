extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var turns_left = 0
var enemies = null

var turns_til_wave = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(turns_left, enemies):
	self.turns_left = turns_left
	self.enemies = enemies
	self.turns_til_wave = self.enemies.get_turns_til_next_wave()
	if self.turns_til_wave == null:
		get_node("Label").set_text("Timed Clear: " + str(self.turns_left) + " Turns Remaining")
	else:
		get_node("Label").set_text("Timed Clear: " + str(self.turns_left) + " Turns Remaining" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")

func update():
	self.turns_left -= 1
	
	if self.turns_til_wave != null:
		if self.turns_til_wave == 0:
			self.turns_til_wave = self.enemies.get_turns_til_next_wave()
		else:
			self.turns_til_wave -= 1
	
	if self.turns_til_wave == null:
		get_node("Label").set_text("Timed Clear: " + str(self.turns_left) + " Turns Remaining")
	else:	
		get_node("Label").set_text("Timed Clear: " + str(self.turns_left) + " Turns Remaining" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")