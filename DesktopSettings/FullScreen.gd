extends "Setting.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	var fullscreened = Globals.get("display/fullscreen")
	get_node("CheckBox").set_pressed(fullscreened)
	get_node("CheckBox").connect("pressed", self, "handle_pressed")
	
func handle_pressed():
	if OS.is_window_fullscreen():
		OS.set_window_fullscreen(false)
		OS.set_window_maximized(true)
		var resolution = get_parent().get_node("Resolution").current_resolution
		OS.set_window_size(resolution)
		print("current resolution: ", resolution)
		Globals.set("display/fullscreen", false)
		Globals.save()
	else:
		OS.set_window_fullscreen(true)
		OS.set_window_maximized(false)
		Globals.set("display/fullscreen", true)
		Globals.save()

#	if event.is_action("toggle_fullscreen") and event.is_pressed():
#		if OS.is_window_fullscreen():
#			OS.set_window_fullscreen(false)
#			OS.set_window_maximized(true)
#			var current_size = OS.get_window_size()
#			OS.set_window_size(Vector2(670, current_size.y))
#		else:
#			OS.set_window_fullscreen(true)
#			OS.set_window_maximized(false)
#			