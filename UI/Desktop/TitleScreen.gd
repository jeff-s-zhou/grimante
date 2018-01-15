extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	var tween = get_node("Tween")
	tween.interpolate_property(get_node("Title"), "visibility/opacity", \
	0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(get_node("Label"), "visibility/opacity", \
	0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_complete")

func _input(event):
	if get_node("/root/InputHandler").is_select(event):
		set_process_input(false)
		var tween = get_node("Tween")
		var start_opacity = get_node("Title").get_opacity()
		tween.interpolate_property(get_node("Title"), "visibility/opacity", \
		start_opacity, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		
		start_opacity = get_node("Label").get_opacity()
		tween.interpolate_property(get_node("Label"), "visibility/opacity", \
		start_opacity, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_complete")
		get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn")