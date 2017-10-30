extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func play(frame):
	get_node("Node2D/AnimatedSprite").play(frame)
	get_node("AnimationPlayer").play("glow")
	
func animate_spin_in(time, delay=0):
	get_node("Tween").interpolate_property(self, "transform/scale", Vector2(2, 2), Vector2(1, 1), time, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, time, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	#get_node("Tween").interpolate_property(get_node("Node2D"), "transform/rot", 60, 0, time, Tween.TRANS_QUAD, Tween.EASE_IN, delay)
	get_node("Tween").interpolate_property(get_node("Node2D/AnimatedSprite"), "transform/rot", 0, -360, time, Tween.TRANS_CUBIC, Tween.EASE_OUT, delay)
	get_node("Tween").start()
	
func animate_fade_in(delay):
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
	get_node("Tween").start()