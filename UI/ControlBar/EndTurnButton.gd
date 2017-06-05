extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var pressed_flag
signal holding
signal released

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("TextureButton").connect("pressed", self, "is_pressed")
	get_node("TextureButton").connect("released", self, "is_released")
	
func set_disabled(flag):
	get_node("TextureButton").set_disabled(flag)

func is_pressed():
	pressed_flag = true
	print("is pressed")
	get_node("Tween").interpolate_callback(self, 0.4, "start_countdown_timer")
	get_node("Tween").start()
	
func start_countdown_timer():
	print("starting countdown timer")
	if pressed_flag:
		emit_signal("holding")
	
func is_released():
	pressed_flag = false
	emit_signal("released")