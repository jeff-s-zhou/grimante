extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal bar_filled

var animating_flag = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func start():
	show()
	self.animating_flag = true
	var bar = get_node("TextureProgress")
	get_node("Tween").interpolate_property(bar, "range/value", 0, 100, 1.5, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").interpolate_callback(self, 1.5, "bar_filled")
	get_node("Tween").start()
	
func bar_filled():
	self.animating_flag = false
	hide()
	emit_signal("bar_filled")

func stop():
	self.animating_flag = false
	hide()
	get_node("Tween").stop_all()
	get_node("Tween").reset_all()