extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#animate_extend(Vector2(0, 400), 40)
	pass

func animate_extend(distance_length, angle):
	print(str(angle) + "is the angle")
	set_rot(angle + 3.14)
	var sprite = get_node("Sprite")
	
	var distance = Vector2(0, distance_length)
	
	get_node("Tween").interpolate_property(sprite, "transform/pos", sprite.get_pos(), sprite.get_pos() + distance, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	
func animate_retract(distance_length, speed):
	var sprite = get_node("Sprite")
	var distance = Vector2(0, distance_length)
	get_node("Tween").interpolate_property(sprite, "transform/pos", sprite.get_pos(), sprite.get_pos() - distance, distance_length/speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	set_rotd(0)