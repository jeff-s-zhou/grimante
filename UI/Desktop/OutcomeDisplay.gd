extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar

var next_level = null

var current_level = null

var victory_flag = false

var cleared_level_set = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("NextLevelButton").connect("pressed", self, "next_level")
	get_node("LevelSelectButton").connect("pressed", self, "level_select")
	get_node("RetryButton").connect("pressed", self, "restart")
	set_opacity(0)
	
func fade_in():
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween").start()
	if self.victory_flag:
		get_node("OutcomeMessage").animate_glow()
	
func initialize_victory(next_level, current_level, turn):
	self.next_level = next_level
	self.current_level = current_level
	self.victory_flag = true
	get_node("OutcomeMessage").set_victory()
	
#	if next_level.is_boss_level():
#		if get_node("/root/State").is_boss_level_unlocked():
#			pass
#		else:
#			get_node("NextLevelButton").set_disabled(true)
#			get_node("BossLevelLockedText").show()
	
	var score = current_level.get_score(turn)
	get_node("/root/State").save_level_progress(self.current_level.name, score)
	
	if next_level == null:
		get_node("NextLevelButton").set_disabled(true)
		#get_node("/root/State").cleared_level_set()
		#get_node("ClearedLevelSetText").show()
		#self.cleared_level_set = true
	

func initialize_defeat(next_level, current_level):
	self.victory_flag = false
	get_node("OutcomeMessage").set_defeat()
	if next_level == null:
			get_node("NextLevelButton").set_disabled(true)
	self.next_level = next_level
	self.current_level = current_level
	get_node("/root/State").save_level_progress(self.current_level.name, "F")
	
func next_level():
	var combat_resource = get_node("/root/global").combat_resource
	get_node("/root/global").goto_scene(combat_resource, {"level": self.next_level})
	
func restart():
	var combat_resource = get_node("/root/global").combat_resource
	get_node("/root/global").goto_scene(combat_resource, {"level": self.current_level})
	
func level_select():
	if self.cleared_level_set:
		get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSetSelect.tscn", {"cleared_level_set":self.cleared_level_set})
	else:
		var level_set = get_node("/root/State").current_level_set
		get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSelect.tscn", {"level_set":level_set})