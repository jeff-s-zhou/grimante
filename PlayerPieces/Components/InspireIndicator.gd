extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func animate_clear_inspire():
	get_node("Highlights").set_opacity(0)
	get_node("ComboSparkleManager").animate_clear_assist()


func animate_inspire_ready(type):
	get_node("/root/AnimationQueue").update_animation_count(1)
	var highlights = get_node("Highlights")
	highlights.set_opacity(0)
	highlights.get_node("InspireArrow").set_rotd(0)
	
	get_node("Highlights/InspireText").play(type)
	get_node("Highlights/InspireArrow").play(type)
	get_node("Tween").interpolate_property(highlights, "visibility/opacity", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()

	get_node("AnimationPlayer").play("hover")
	get_node("ComboSparkleManager").animate_activate_assist(type)
	yield(get_node("Tween"), "tween_complete")
	get_node("/root/AnimationQueue").update_animation_count(-1)
	emit_signal("animation_done")

func animate_give_inspire(type, target_piece):
	get_node("/root/AnimationQueue").update_animation_count(1)
	
	get_node("Highlights/InspireText").play(type)
	get_node("Highlights/InspireArrow").play(type)
	get_node("AnimationPlayer").stop()
	
	get_node("Tween").interpolate_property(get_node("Highlights"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)	
	var arrow = get_node("Highlights/InspireArrow")
	var final_pos = arrow.get_pos() + Vector2(0, -15)
	get_node("Tween").interpolate_property(arrow, "transform/pos", arrow.get_pos(), final_pos, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT) 
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	yield(get_node("Tween"), "tween_complete")

	
	var pos_difference = target_piece.get_global_pos() - get_parent().get_global_pos()
	print("pos difference is ", pos_difference)
	get_node("ComboSparkleManager").animate_assist(type, pos_difference)
	yield(get_node("ComboSparkleManager"), "animation_done")
	
	
	get_node("/root/AnimationQueue").update_animation_count(-1)
	emit_signal("animation_done")


func animate_receive_inspire(type):
	get_node("/root/AnimationQueue").update_animation_count(1)
	var arrow = get_node("Highlights/InspireArrow")
	arrow.set_pos(Vector2(0, -50))
	arrow.set_rotd(180)

	var final_pos = Vector2(0, -35)
	get_node("Highlights/InspireText").play(type)
	get_node("Highlights/InspireArrow").play(type)
	get_node("Tween").interpolate_property(arrow, "transform/pos", arrow.get_pos(), final_pos, 0.3, Tween.TRANS_SINE, Tween.EASE_IN) 
	get_node("Tween").interpolate_property(get_node("Highlights"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	yield(get_node("Tween"), "tween_complete")
	get_node("Tween 2").interpolate_property(get_node("Highlights"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	emit_signal("animation_done")
	get_node("/root/AnimationQueue").update_animation_count(-1)