extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var settings
const SettingsPrototype = preload("res://DesktopSettings/Settings.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	get_node("T").initialize()
	get_node("T/SettingsButton").connect("pressed", self, "go_to_settings")
	get_node("T/BackButton").connect("pressed", self, "exit_menu")
	get_node("T/ExitButton").connect("pressed", self, "exit_game")

func _input(event):
	if get_node("/root/InputHandler").is_ui_cancel(event):
		if is_visible():
			exit_menu()
		else:
			show()
			get_node("T").animate_slide_in()
			get_parent().blur_darken(0.2)
			get_parent().pause()

func exit_menu():
	get_node("T").animate_slide_out()
	get_parent().blur_lighten(0.2)
	get_parent().unpause()
	yield(get_node("T"), "animation_done")
	hide()

func initialize(level_schematic):
	get_node("T/Label").set_text(level_schematic.name.to_upper())
	var score = get_node("/root/State").get_level_score(level_schematic.id)
	var has_previous_score = score != null and score != 5
	if has_previous_score: #already attempted but not full score
		var turn = level_schematic.get_turn_to_improve_score(score)
		if turn == 1:
			get_node("T/TurnSubtext").set_bbcode(
			"[center]CLEAR IN [color=#00ffcc]" + str(turn) + "[/color] TURN TO BEAT YOUR SCORE[/center]")
		else:
			get_node("T/TurnSubtext").set_bbcode(
			"[center]CLEAR IN [color=#00ffcc]" + str(turn) + "[/color] TURNS TO BEAT YOUR SCORE[/center]")
	
	if get_node("/root/State").current_level_set != null:
		var set_progress = get_node("/root/State").get_level_set_progress()
		var set_number = get_node("/root/State").current_level_set.id
		get_node("T/SetProgress").set_text("SET " + str(set_number) + " - " +
		str(set_progress[0]) + "/" + str(set_progress[1]) + " LEVELS COMPLETED")
			
			
func go_to_settings():
	get_node("T").animate_slide_out()
	
	self.settings = SettingsPrototype.instance()
	add_child(self.settings)
	self.settings.initialize() #do this after backbutton so that backbutton also gets initialized
	
	
	self.settings.set_pos(Vector2(236, 150))
	self.settings.animate_slide_in()
	

func back_from_settings():
	self.settings.animate_slide_out()
	yield(self.settings, "animation_done")
	self.settings.queue_free()
	get_node("T").animate_slide_in()
	
	
func exit_game():
	get_tree().quit()
