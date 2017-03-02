extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var enemies_dead_this_turn = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func reset_enemy_killcount():
	self.enemies_dead_this_turn = 0
	
func track_enemy_death():
	self.enemies_dead_this_turn += 1
	if self.enemies_dead_this_turn >= 3:
		adjust_tides(10)

func adjust_tides(amount):
	var bar = get_node("TextureProgress")
	bar.set_value(bar.get_value() + amount)
	get_node("Label").set_text(str(bar.get_value()))