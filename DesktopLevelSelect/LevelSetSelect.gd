extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#add_child(levels)
	
	var cleared_level_set = get_node("/root/global").get_param("cleared_level_set")
	#either null, false, or true
	if cleared_level_set:
		pass
		#get the button associated with the current level set and play its cleared animation
	else:
		get_node("/root/State").current_level_set = null
	
	for level_set in get_node("/root/Levels").get_level_sets():
		var id_str = "T/" + str(level_set.id)
		get_node(id_str).connect("pressed", self, "goto_level_set")
		get_node(id_str).initialize(level_set)
		
	get_node("T").initialize()
	get_node("T").animate_slide_in()


func goto_level_set(level_set):
	get_node("T").animate_slide_out()
	yield(get_node("T"), "animation_done")
	get_node("/root/State").current_level_set = level_set
	get_node("/root/global").goto_scene("res://DesktopLevelSelect/LevelSelect.tscn", {"level_set":level_set})