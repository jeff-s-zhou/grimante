extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func display_overlay(unit_name):
	get_node("/root/AnimationQueue").enqueue(self, "animate_display_overlay", true, [unit_name])
	
func animate_display_overlay(unit_name):
	get_node("/root/Combat").darken(0.3, 0.2)
	get_node("AnimatedSprite").play(unit_name)
	if unit_name == "Archer":
		get_node("AnimationPlayer").play("SwoopRightToLeft")
	else:
		get_node("AnimationPlayer").play("SwoopLeftToRight")
	yield(get_node("AnimationPlayer"), "finished")
	get_node("/root/Combat").lighten(0.3, 0.2)
	emit_signal("animation_done")


