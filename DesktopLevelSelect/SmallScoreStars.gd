extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func display_score(score):
	var delay = 0
	var diff = 0.3
	var animation_time = 0.8
	if score == 5:
		for i in range(1, 6):
			get_node(str(i)).play("yellow")
	else:
		for i in range(1, score + 1):
			get_node(str(i)).play("full")