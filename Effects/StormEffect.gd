extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done
signal count_animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate_set_rain():
	get_node("RainParticles").set_emitting(true)
	get_node("Tween").interpolate_property(get_node("RainParticles"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	emit_signal("count_animation_done")
	
func animate_lightning():
	get_node("AnimationPlayer").play("Flash")
	yield(get_node("AnimationPlayer"), "finished")
	emit_signal("animation_done")
	emit_signal("count_animation_done")
	
func animate_hide_rain():
	get_node("Tween").interpolate_property(get_node("RainParticles"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	yield(get_node("Tween"), "tween_complete")
	get_node("RainParticles").set_emitting(false)
	emit_signal("count_animation_done")
	