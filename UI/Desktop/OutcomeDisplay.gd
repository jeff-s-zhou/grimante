extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar

var next_level = null

var current_level = null

var victory_flag = false

var next_set_flag = false

var already_completed_flag = false

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("NextLevelButton").connect("pressed", self, "next_level")
	get_node("LevelSelectButton").connect("pressed", self, "level_select")
	get_node("RetryButton").connect("pressed", self, "restart")
	set_opacity(0)
	

func _enter_tree():
	set_pos(get_node("/root/global").get_resolution()/2)
	
	
func fade_in():
	get_parent().blur_darken(0.3)
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween").start()
	if self.victory_flag:
		get_node("OutcomeMessage").animate_glow()
		get_node("SamplePlayer").play("victory")
	else:
		get_node("AnimationPlayer").play("lose")
		get_node("SamplePlayer").play("defeat")

func fade_out():
	get_parent().blur_lighten(0.2)
	get_node("Tween").interpolate_property(self, "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_parent().transition_out()
	yield(get_parent(), "animation_done")
	emit_signal("animation_done")
	
	
func initialize_victory(next_level, current_level, cleared_turn):
	self.next_level = next_level
	self.current_level = current_level
	self.victory_flag = true
	get_node("OutcomeMessage").set_victory()

	var score = current_level.get_score(cleared_turn)
	if score != null and score != 5:
		get_node("BetterScoreLabel").show()
	get_node("ScoreStars").display_score(score)
	self.already_completed_flag = get_node("/root/State").is_set_completed() #check if we already completed the set
	
	get_node("/root/State").save_level_progress(self.current_level.id, score)
	set_progress_label()
	
	get_node("/root/State").request_attempt_session_id()
	
	if next_level == null:
		if get_node("/root/State").is_set_completed():
			self.next_set_flag = true
			get_node("NextLevelButton/Toppings/Label").set_text("NEXT SET")
		else:
			get_node("NextLevelButton").set_disabled(true)
	

func initialize_defeat(next_level, current_level):
	self.victory_flag = false
	get_node("OutcomeMessage").set_defeat()
	if next_level == null:
			get_node("NextLevelButton").set_disabled(true)
	self.next_level = next_level
	self.current_level = current_level
	get_node("/root/State").save_level_progress(self.current_level.name, 0)
	set_progress_label()
	
func set_progress_label():
	if get_node("/root/State").current_level_set != null:
		var set_progress = get_node("/root/State").get_level_set_progress()
		get_node("ProgressLabel").set_text(str(set_progress[0]) + "/" + str(set_progress[1]) + " LEVELS COMPLETED")
		
func next_level():
	fade_out()
	yield(self, "animation_done")
	if self.next_set_flag:
		get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn", 
		{"cleared_level_set":!self.already_completed_flag})
	else:
		var combat_resource = get_node("/root/global").combat_resource
		get_node("/root/global").goto_scene(combat_resource, {"level": self.next_level})
	
func restart():
	fade_out()
	yield(self, "animation_done")
	var combat_resource = get_node("/root/global").combat_resource
	get_node("/root/global").goto_scene(combat_resource, {"level": self.current_level})
	
func level_select():
	fade_out()
	yield(self, "animation_done")
	if self.next_set_flag:
		get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn", 
		{"cleared_level_set":!self.already_completed_flag})
	else:
		var level_set = get_node("/root/State").current_level_set
		get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSelect.tscn", {"level_set":level_set})