extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate_darken(time):
	set_opacity(0)
	show()
	get_node("TextureFrame").set_stop_mouse(true)
	get_node("TextureFrame").set_ignore_mouse(false)
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	
	
func animate_lighten(time):
	var amount = get_opacity()
	get_node("Tween").interpolate_property(self, "visibility/opacity", amount, 0, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	get_node("TextureFrame").set_stop_mouse(false)
	get_node("TextureFrame").set_ignore_mouse(true)
	hide()
	
