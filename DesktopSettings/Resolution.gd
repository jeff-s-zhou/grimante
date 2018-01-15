extends "Setting.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var current_resolution

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var y = Globals.get("display/test_height")
	var x = Globals.get("display/test_width")
	var resolution = Vector2(x, y)
	self.current_resolution = resolution
	if resolution == Vector2(1024, 768):
		get_node("Node2D/OptionButton").select(0)
	elif resolution == Vector2(800, 600):
		get_node("Node2D/OptionButton").select(1)
	get_node("Node2D/OptionButton").connect("item_selected", self, "handle_resolution_selected")
	
func handle_resolution_selected(item):
	var resolution
	if item == 0:
		resolution = Vector2(1024, 768)
	elif item == 1:
		resolution = Vector2(800, 600)
	
	self.current_resolution = resolution
	OS.set_window_size(resolution)
	#print("Globals persisting: ", Globals.is_persisting("display/height"))
	Globals.set("display/test_height", resolution.y)
	Globals.set("display/test_width", resolution.x)
	Globals.save()