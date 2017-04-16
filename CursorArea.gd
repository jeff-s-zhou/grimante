
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	
	
	
func _input(ev):
	if ev.type==InputEvent.MOUSE_MOTION or ev.type==InputEvent.SCREEN_TOUCH:
		set_pos(ev.pos)


func get_piece_hovered():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.get_name() == "CollisionArea": #hackey, since CollisionArea is the one that has monitorable enabled but ClickArea doesn't
			return area.get_parent()
	return null
	
func get_piece_or_location_hovered():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.get_name() == "CollisionArea": #hackey, since CollisionArea is the one that has monitorable enabled but ClickArea doesn't
			return area.get_parent()
	for area in areas:
		if area.get_name().find("Location") != -1: #the Locations have unique modifiers to their name because they're all children of one class
			return area
	return null
	
