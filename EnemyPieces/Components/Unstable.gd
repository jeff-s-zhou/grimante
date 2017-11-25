extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	

func set_emitting(flag):
	get_node("UnstableParticles").set_emitting(flag)
