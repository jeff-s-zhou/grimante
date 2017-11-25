extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func animate_explode(delay):
	get_node("OutExplosion").set_enabled(true)
	get_node("UpExplosion").set_enabled(true)
#	
#	get_node("/root/Combat").darken(0.2, 0.2, delay)
#	
#	get_node("Tween").interpolate_property(get_node("OutExplosion"), "energy", 0.01, 5, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1 + delay)
#	get_node("Tween").interpolate_property(get_node("UpExplosion"), "energy", 0.01, 5, 0.2, Tween.TRANS_SINE, Tween.EASE_IN, delay)
#	get_node("Tween").start()
#	yield(get_node("Tween"), "tween_complete")
#	yield(get_node("Tween"), "tween_complete")
#
#
	#get_node("/root/Combat").lighten(0.3)
	var ring = get_node("Ring")
	ring.set_scale(Vector2(0.3, 0.3))
	ring.set_opacity(1)
	get_node("Tween").interpolate_property(ring, "visibility/opacity", \
	1, 0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN, 0.2 + delay)
	get_node("Tween").interpolate_property(ring, "transform/scale", \
	Vector2(0.3, 0.3), Vector2(1.6, 1.6), 0.7, Tween.TRANS_QUAD, Tween.EASE_OUT, delay)

	get_node("Tween").interpolate_property(get_node("OutExplosion"), "energy", 5, 0.01, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	get_node("Tween").interpolate_property(get_node("UpExplosion"), "energy", 5, 0.01, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	yield(get_node("Tween"), "tween_complete")
	yield(get_node("Tween"), "tween_complete")
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	
	get_node("OutExplosion").set_enabled(false)
	get_node("UpExplosion").set_enabled(false)