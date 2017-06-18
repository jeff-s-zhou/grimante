extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func set_shifting_direction(direction):
	self.set_rotd(180 + (direction * -60))
	
func animate_rotate():
	var final_value = self.get_rotd() - 60
	get_node("Tween").interpolate_property(self, "transform/rot", self.get_rotd(), final_value, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	
func highlight():
	get_node("HighlightSprite").show()

func reset_highlight():
	get_node("HighlightSprite").hide()
