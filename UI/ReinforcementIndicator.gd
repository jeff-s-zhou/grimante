extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func display(type):
	get_node("Sprite").play(type)
	get_node("Sprite 2").play(type)
	get_node("Sprite 3").play(type)
	
func animate_summon():
	get_parent().play_summon_sound()
	get_node("AnimationPlayer").play("Summon")
	yield(get_node("AnimationPlayer"), "finished")
	get_node("Sprite 3").set_opacity(0)
	emit_signal("animation_done")