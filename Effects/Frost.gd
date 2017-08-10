extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func flash_frost():
	show()
	print("flash frosting")
	var left_mask = get_node("Light2D1")
	var right_mask = get_node("Light2D")
	left_mask.set_pos(Vector2(6, 0))
	right_mask.set_pos(Vector2(-6, 0))
	set_opacity(1)
	
	get_node("Tween").interpolate_property(left_mask, "transform/pos", left_mask.get_pos(), Vector2(-450, 0), 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween").interpolate_property(right_mask, "transform/pos", right_mask.get_pos(), Vector2(450, 0), 0.8, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	clear()
	
func clear():
	get_node("Tween").interpolate_property(self, "visibility/opacity", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	