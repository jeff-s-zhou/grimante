extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate_darken(time, emit_signal=true):
	set_opacity(0)
	show()
	get_node("TextureFrame").set_stop_mouse(true)
	get_node("TextureFrame").set_ignore_mouse(false)
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	if emit_signal:
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")
	
	
func animate_lighten(time, emit_signal=true):
	var amount = get_opacity()
	get_node("Tween").interpolate_property(self, "visibility/opacity", amount, 0, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	if emit_signal:
		emit_signal("animation_done")
#	get_node("Timer").set_wait_time(0.2)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	get_node("TextureFrame").set_stop_mouse(false)
	get_node("TextureFrame").set_ignore_mouse(true)
	hide()
	
