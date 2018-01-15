extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate_attack(global_target_pos, speed):
#	delay = max(delay, 0)
#	get_node("Timer").set_wait_time(delay)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	show()
	var global_start_pos = get_global_pos()
	var difference = global_target_pos - global_start_pos
	var time = difference.length()/speed
	get_node("SamplePlayer").play("shuriken")
	
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), get_pos() + difference, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	queue_free()