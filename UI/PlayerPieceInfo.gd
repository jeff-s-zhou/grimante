extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var label_x = get_viewport_rect().size.width/2 - get_node("Label").get_size().width/2
	get_node("Label").set_pos(Vector2(label_x, 200))

	var tabs_x = get_viewport_rect().size.width/2 - get_node("TabContainer").get_size().width/2
	get_node("TabContainer").set_pos(Vector2(tabs_x, 300))
	
	
func set_info(unit_name, overview_text, active_text, passive_text, ultimate_text):
	get_node("Label").set_text(unit_name)
	yield(get_tree(), "idle_frame")
	var label_x = get_viewport_rect().size.width/2 - get_node("Label").get_size().width/2
	get_node("Label").set_pos(Vector2(label_x, 200))
	get_node("TabContainer/OVERVIEW").set_bbcode(overview_text)
	get_node("TabContainer/ATTACK").set_bbcode(active_text)
	get_node("TabContainer/PASSIVE").set_bbcode(passive_text)