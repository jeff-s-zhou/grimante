extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var ultimate_charging = false 

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _process(delta):
	if get_node("ProgressBar").get_value() == 118:
		print("end charging")
		get_parent().cast_ultimate()
		end_charging()
	
	
func begin_charging():
	ultimate_charging = true 
	show()
	set_process(true)
	get_node("/root/Combat").darken(0.2, 0.3)
	get_node("AnimationPlayer").play("Flash")
	get_node("Tween").interpolate_property(get_node("ProgressBar"), "range/value", 0, 118, 1.3, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	
func end_charging():
	ultimate_charging = false 
	hide()
	set_process(false)
	get_node("/root/Combat").lighten(0.2, 0.2)
	get_node("Tween").stop_all()
	get_node("AnimationPlayer").stop()
	get_node("ProgressBar").set_value(0) 
	
