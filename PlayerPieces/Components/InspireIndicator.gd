extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var ASSIST_TYPES = get_node("/root/Combat/AssistSystem").ASSIST_TYPES

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func animate_inspire_ready(type):
	self.set_opacity(0)
	get_node("InspireArrow").set_rotd(0)
	self.show()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	get_node("InspireText").play(type)
	get_node("InspireArrow").play(type)
	get_node("AnimationPlayer").play("hover")

func animate_give_inspire(type):
	get_node("InspireText").play(type)
	get_node("InspireArrow").play(type)
	get_node("AnimationPlayer").stop()
	
	get_node("Tween").interpolate_property(get_node("InspireText"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	var arrow = get_node("InspireArrow")
	var final_pos = arrow.get_pos() + Vector2(0, -15)
	
	get_node("Tween").interpolate_property(arrow, "transform/pos", arrow.get_pos(), final_pos, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT) 
	get_node("Tween").interpolate_property(arrow, "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	self.hide()
	
func animate_receive_inspire(type):
	
	var arrow = get_node("InspireArrow")
	arrow.set_opacity(0)
	arrow.set_pos(Vector2(0, -50))
	arrow.set_rotd(180)
	
	get_node("InspireText").set_opacity(0)
	
	self.show()
	var final_pos = Vector2(0, -35)
	get_node("InspireText").play(type)
	get_node("InspireArrow").play(type)
	get_node("Tween").interpolate_property(arrow, "transform/pos", arrow.get_pos(), final_pos, 0.3, Tween.TRANS_SINE, Tween.EASE_IN) 
	get_node("Tween").interpolate_property(arrow, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_QUAD, Tween.EASE_OUT)
	get_node("Tween").interpolate_property(get_node("InspireText"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 1, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	emit_signal("animation_done")
	self.hide()
	self.set_opacity(1)