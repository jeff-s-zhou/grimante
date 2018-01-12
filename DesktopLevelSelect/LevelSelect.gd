extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const level_set_button_prototype = preload("res://DesktopLevelSelect/LongTextureLabelButton.tscn")

const SettingsPrototype = preload("res://DesktopSettings/Settings.tscn")

var settings

var level_set

var level_buttons = []

var level_count = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	set_process_input(true)
	var y_position = 170
	var hard_y_position = 170
	
	self.level_set = get_node("/root/global").get_param("level_set")
	
	get_node("T/Label").set_text(self.level_set.name.to_upper())
	
	get_node("T/BackButton").connect("pressed", self, "back")
	
	var first_attempt = false
	var progress = get_node("/root/State").get_level_set_progress(self.level_set)
	if progress[0] == 0:
		first_attempt = true

	for level in self.level_set.get_levels():
		level_count += 1
		var is_first_level = level_count == 1
		create_new_level_button(level, y_position, !is_first_level and first_attempt)
		y_position += 78


	get_node("T").initialize()
	get_node("T").animate_slide_in()
	
	
func _input(event):
	if get_node("/root/InputHandler").is_debug(event):
		for level_button in self.level_buttons:
			level_button.debug()


func create_new_level_button(level, y_position, disabled=false):
	var score = get_node("/root/State").get_level_score(level.id, self.level_set.id)
	var level_button = self.level_set_button_prototype.instance()
	level_button.initialize(level, score, disabled)
	var screen_size = get_node("/root/global").get_resolution()
	level_button.set_pos(Vector2(screen_size.x/2, y_position))
	level_button.connect("pressed", self, "goto_level")
	get_node("T").add_child(level_button)
	self.level_buttons.append(level_button)

	
func goto_level(level):
	get_node("T").animate_slide_out()
	yield(get_node("T"), "animation_done")
	get_node("/root/State").request_attempt_session_id()
	get_node("/root/global").goto_scene(get_node("/root/global").combat_resource, {"level":level})
	
	
func go_to_settings():
	get_node("T").animate_slide_out()
	yield(get_node("T"), "animation_done")
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

	
func back():
	get_node("T").animate_slide_out()
	yield(get_node("T"), "animation_done")
	get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn")