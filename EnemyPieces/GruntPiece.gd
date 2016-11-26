
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var movement_value = Vector2(0, 1)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func hover_highlight():
	if self.action_highlighted:
		get_node("Sprite").play("attack_range_hover")
	
func hover_unhighlight():
	if self.action_highlighted:
		get_node("Sprite").play("attack_range")

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	self.action_highlighted = true
	get_node("Sprite").play("attack_range")
	
func unhighlight():
	self.action_highlighted = false
	get_node("Sprite").play("default")
	
func attack_highlight():
	get_node("Sprite").play("attack_range")
	
func initialize(max_hp):
	self.max_hp = max_hp


