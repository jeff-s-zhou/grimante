extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var settings
const SettingsPrototype = preload("res://DesktopSettings/Settings.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(false)
	get_node("T").initialize()
	get_node("T/SettingsButton").connect("pressed", self, "go_to_settings")
	get_node("T/BackButton").connect("pressed", self, "exit_menu")
	get_node("T/ExitButton").connect("pressed", self, "exit_game")
	get_node("T/LevelSelectButton").connect("pressed", self, "go_to_level_select")

func _input(event):
	if get_node("/root/InputHandler").is_ui_cancel(event):
		toggle()


func toggle():
	if is_visible():
		if self.settings != null: #in the settings screen
			back_from_settings()
		else:
			exit_menu()
	else:
		display()


func display():
	show()
	get_node("T").animate_slide_in()
	get_node("BlurDarkenLayer").animate_darken(0.2, false)
	set_process_input(true)
	get_parent().pause(true)

func exit_menu():
	get_node("T").animate_slide_out()
	get_node("BlurDarkenLayer").animate_lighten(0.2, false)
	set_process_input(false)
	get_parent().unpause(true)
	yield(get_node("T"), "animation_done")
	hide()

func initialize(level_schematic):
	get_node("T/Label").set_text(level_schematic.name.to_upper())
	var score = get_node("/root/State").get_level_score(level_schematic.id)
	var has_previous_score = score != null and score != 0 and score < 5
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
	
	
func go_to_level_select():
	get_parent().transition_out()
	yield(get_parent(), "animation_done")
	var level_set = get_node("/root/State").current_level_set
	get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSelect.tscn", {"level_set":level_set})
	

func back_from_settings():
	self.settings.animate_slide_out()
	yield(self.settings, "animation_done")
	self.settings.queue_free()
	self.settings = null
	get_node("T").animate_slide_in()
	
	
func exit_game():
	get_tree().quit()
