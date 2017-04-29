extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var platform
var PLATFORMS

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.platform = get_node("/root/global").platform
	self.PLATFORMS = get_node("/root/global").PLATFORMS

func is_select(event):
	if self.platform == self.PLATFORMS.Android:
		return event.type == InputEvent.SCREEN_TOUCH and event.is_pressed()
	elif self.platform == self.PLATFORMS.iOS:
		return event.type == InputEvent.SCREEN_TOUCH and event.is_pressed()
	elif self.platform == self.PLATFORMS.PC:
		return event.is_action("select") and event.is_pressed()
		
	
func is_deselect(event):
	var is_mouse = event.is_action("deselect") and event.is_pressed()
	return is_mouse
	
func is_ui_accept(event):
	if self.platform == self.PLATFORMS.Android:
		return false
		#return event.type == InputEvent.SCREEN_DRAG
	elif self.platform == self.PLATFORMS.iOS:
		return event.type == InputEvent.SCREEN_DRAG
	elif self.platform == self.PLATFORMS.PC:
		return event.is_action("ui_accept") and event.is_pressed()