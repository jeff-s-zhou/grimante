
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var coords

signal location_is(location)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite").set_self_opacity(0.4)
	connect("mouse_enter", self, "_mouse_entered")
	connect("mouse_exit", self, "_mouse_exited")
	
func set_coords(coords):
	self.coords = coords

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	external_set_opacity()
	
func attack_highlight():
	external_set_opacity(0.7)
	
func unhighlight():
	external_set_opacity(0.4)
	
func _mouse_entered():
	emit_signal("location_is", self)
	get_node("Sprite").set_self_opacity(0.7)

func _mouse_exited():
	#get_parent().current_location = null
	#emit_signal("location_is", null)
	get_node("Sprite").set_self_opacity(0.4)
	
func external_set_opacity(value=1.0):
	get_node("Sprite").set_self_opacity(value)
	
func get_size():
	return get_node("Sprite").get_item_rect().size
	
