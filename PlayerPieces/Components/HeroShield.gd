extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate_explode():
	get_node("Sprite").hide()
	get_node("ShieldExplosionParticles").set_emit_timeout(0.3)
	get_node("ShieldExplosionParticles").set_emitting(true)
	
func display():
	get_node("Sprite").show()