extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var beat_game = get_node("/root/global").get_param("beat_game")
	if beat_game:
		get_node("T/Label").set_text("THANK YOU FOR PLAYING")
	
	get_node("T").initialize()
	get_node("T").animate_slide_in()
	get_node("Tween").interpolate_property(get_node("DarkenLayer"), "visibility/opacity", 0, 0.3, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
	get_node("T/BackButton").connect("pressed", self, "go_to_level_set_select")


func go_to_level_set_select():
	get_node("T").animate_slide_out()
	yield(get_node("T"), "animation_done")
	get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn")