extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func set_shifting_direction(direction):
	self.set_rotd(180 + (direction * -60))
	
func highlight():
	get_node("HighlightSprite").show()

func reset_highlight():
	get_node("HighlightSprite").hide()
