extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_victory():
	get_node("Base").play("victory")
	
func set_defeat():
	get_node("Base").play("defeat")
	
func animate_glow():
	get_node("Tween").interpolate_property(get_node("Glow"), "visibility/opacity", 0, 1, 0.7, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Tween").interpolate_property(get_node("Glow"), "visibility/opacity", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)
	get_node("Tween").start()