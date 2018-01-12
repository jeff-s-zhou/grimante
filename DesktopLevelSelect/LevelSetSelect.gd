extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const SettingsPrototype = preload("res://DesktopSettings/Settings.tscn")

var settings

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	
	for level_set in get_node("/root/Levels").get_level_sets():
		var id_str = "T/" + str(level_set.id)
		get_node(id_str).connect("pressed", self, "goto_level_set")
		get_node(id_str).initialize(level_set)
		
	set_process_input(true)
	
	
	var first_clear = get_node("/root/global").get_param("cleared_level_set")
	#either null, false, or true
	if first_clear:
		var id = get_node("/root/State").current_level_set.id
		if id < 9: #current level cap:
			var id_str = "T/" + str(id + 1)
			#get the button associated  with the next level set and play its cleared animation
			get_node(id_str).defrost()
	
	
	get_node("/root/State").current_level_set = null
	
	get_node("T").initialize()
	get_node("T").animate_slide_in()
	
	
func _input(event):
	if get_node("/root/InputHandler").is_debug(event):
		for i in range(1, 10):
			var node_str = "T/" + str(i)
			get_node(node_str).debug()


func goto_level_set(level_set):
	get_node("T").animate_slide_out()
	yield(get_node("T"), "animation_done")
	get_node("/root/State").current_level_set = level_set
	get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSelect.tscn", {"level_set":level_set})
	
	
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