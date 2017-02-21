extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

var is_playing = false

	
func animate_display_overlay(unit_name):
	is_playing = true
	get_node("/root/Combat").darken(0.2, 0.4)
	get_node("AnimatedSprite").play(unit_name)
	if unit_name == "Archer":
		get_node("AnimationPlayer").play("SwoopRightToLeft")
	else:
		get_node("AnimationPlayer").play("SwoopLeftToRight")
	yield(get_node("AnimationPlayer"), "finished")
	is_playing = false
	get_node("/root/Combat").lighten(0.2)
	emit_signal("animation_done")

func skip_animation():
	if is_playing:
		is_playing = false
		get_node("AnimationPlayer").stop()
		get_node("AnimatedSprite").set_opacity(0)
		get_node("/root/Combat").lighten(0.1)
		emit_signal("animation_done")