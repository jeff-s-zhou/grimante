extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	hide()

func show():
	get_node("AnimationPlayer").play("glow")
	.show()
	
func hide():
	.hide()
	get_node("AnimationPlayer").stop()
	
func animate_explode():
	get_node("OutExplosion").set_enabled(true)
	get_node("UpExplosion").set_enabled(true)
	
	get_node("/root/Combat").darken(0.2, 0.3, 0.5)
	
	get_node("Tween").interpolate_property(get_node("OutExplosion"), "energy", 0.01, 5, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	get_node("Tween").interpolate_property(get_node("UpExplosion"), "energy", 0.01, 5, 0.4, Tween.TRANS_SINE, Tween.EASE_IN, 0.2)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	
	get_node("Base").hide()
	get_node("Glow").hide()
	
	get_node("/root/Combat").lighten(0.3)
	get_node("Tween").interpolate_property(get_node("OutExplosion"), "energy", 5, 0.01, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_property(get_node("UpExplosion"), "energy", 5, 0.01, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	yield(get_node("Tween"), "tween_complete")
	
	get_node("OutExplosion").set_enabled(false)
	get_node("UpExplosion").set_enabled(false)
	hide()
	get_node("Base").show()
	get_node("Glow").show()