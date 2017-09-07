extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_green(variation):
	if variation == 0:
		get_node("Runes1").play("green1")
		get_node("Runes2").play("green1")
		get_node("AnimationPlayer").play("LeftToRight")
	else:
		get_node("Runes1").play("green2")
		get_node("Runes2").play("green2")
		get_node("AnimationPlayer").play("RightToLeft")

func set_black(variation):
	if variation == 0:
		get_node("Runes1").play("black1")
		get_node("Runes2").play("black1")
		get_node("AnimationPlayer").play("LeftToRight")
	else:
		get_node("Runes1").play("black2")
		get_node("Runes2").play("black2")
		get_node("AnimationPlayer").play("RightToLeft")