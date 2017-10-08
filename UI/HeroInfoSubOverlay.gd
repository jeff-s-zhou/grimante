extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var ASSIST_TYPES = get_node("/root/AssistSystem").ASSIST_TYPES

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func display_info(shielded, movement, inspire_type):
	if shielded:
		get_node("ArmorIcon").show()
	else:
		get_node("ArmorIcon").hide()
	get_node("MovementLabel").set_text(str(movement))
	if inspire_type == ASSIST_TYPES.attack:
		get_node("InspireLabel").set_text("ATK")
	elif inspire_type == ASSIST_TYPES.movement:
		get_node("InspireLabel").set_text("MOV")
	elif inspire_type == ASSIST_TYPES.defense:
		get_node("InspireLabel").set_text("DEF")
	show()