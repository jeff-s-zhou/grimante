extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_health(amount):
	var str_amount = str(amount)
	get_node("Label").set_text(str_amount)
	get_node("Label").show()
#	get_node("AnimatedSprite").set_animation(str_amount)
#	get_node("AnimatedSprite").show()