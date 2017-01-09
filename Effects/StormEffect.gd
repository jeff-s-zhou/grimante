extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate_set_rain():
	get_node("RainParticles").show()
	get_node("Tween").interpolate_property(get_node("RainParticles"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
func animate_lightning():
	get_node("AnimationPlayer").play("Flash")
	yield(get_node("AnimationPlayer"), "finished")
	emit_signal("animation_done")
	get_node("Tween").interpolate_property(get_node("RainParticles"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	