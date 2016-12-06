extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_tooltip(tooltip):
	if tooltip:
		get_node("Panel/Text").set_bbcode(tooltip)
		get_node("Panel").show()
		
func reset():
	self.hide()
	get_node("Panel").hide()
	get_node("Panel/Text").set_bbcode("")
	