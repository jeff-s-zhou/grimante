extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar

var next_level = null

var current_level = null

var victory_flag = false

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
	
func initialize_victory(next_level, current_level):
	self.victory_flag = true
	get_node("OutcomeMessage").set_victory()
	if next_level == null:
			get_node("NextLevelButton").set_disabled(true)
	self.next_level = next_level
	self.current_level = current_level
	
func initialize_defeat(next_level, current_level):
	self.victory_flag = false
	get_node("OutcomeMessage").set_defeat()
	if next_level == null:
			get_node("NextLevelButton").set_disabled(true)
	self.next_level = next_level
	self.current_level = current_level
	
func next_level():
	var combat_resource = get_node("/root/global").combat_resource
	get_node("/root/global").goto_scene(combat_resource, {"level": self.next_level})
	
func restart():
	var combat_resource = get_node("/root/global").combat_resource
	get_node("/root/global").goto_scene(combat_resource, {"level": self.current_level})
	
func level_select():
	get_node("/root/global").goto_scene("res://LevelSelect/LevelSetSelect.tscn")