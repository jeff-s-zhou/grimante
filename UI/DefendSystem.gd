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
	
func initialize(turns_to_hold, enemies):
	self.turns_left = turns_to_hold
	self.enemies = enemies
	self.turns_til_wave = self.enemies.get_turns_til_next_wave()
	get_node("Label").set_text("Hold the Line: " + str(self.turns_left) + " Turns Remaining" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")

func update():
	self.turns_left -= 1
	
	if self.turns_til_wave == 0:
		self.turns_til_wave = self.enemies.get_turns_til_next_wave()
	else:
		self.turns_til_wave -= 1
	get_node("Label").set_text("Hold the Line: " + str(self.turns_left) + " Turns Remaining" + " (Turns Until Next Wave: " + str(self.turns_til_wave) + ")")