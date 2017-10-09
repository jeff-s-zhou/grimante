
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var platform
var PLATFORMS

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	self.platform = get_node("/root/global").platform
	self.PLATFORMS = get_node("/root/global").PLATFORMS
	
	
func set_star_cursor(flag):
	if flag:
		get_node("Sprite").show()
		get_node("Glow").show()
		get_node("AnimationPlayer").play("star_glow")
		get_node("Particles2D").set_emitting(true)
	else:
		get_node("Sprite").hide()
		get_node("Glow").hide()
		get_node("AnimationPlayer").stop_all()
		get_node("Particles2D").set_emitting(false)
	
	
func is_motion(ev):
	if self.platform == self.PLATFORMS.Android:
		return ev.type==InputEvent.SCREEN_TOUCH
	elif self.platform == self.PLATFORMS.iOS:
		return ev.type==InputEvent.SCREEN_TOUCH
	elif self.platform == self.PLATFORMS.PC:
		return ev.type==InputEvent.MOUSE_MOTION


func _input(ev):
	if is_motion(ev):
		set_pos(ev.pos)
	

func get_piece_hovered():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.get_name() == "CollisionArea": #hackey, since CollisionArea is the one that has monitorable enabled but ClickArea doesn't
			return area.get_parent()
	return null
	
func get_location_hovered():
	var areas = get_overlapping_areas()
	for area in areas:
			if area.get_name().find("Location") != -1: #the Locations have unique modifiers to their name because they're all children of one class
				return area
	return null

#this is probably buggy as fuck.
#and is what allows people to select locations sometimes instead of pieces
#only reutrn the areas whose parents return true for is_targetable??
func get_piece_or_location_hovered():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.get_name() == "CollisionArea": 
			var parent = area.get_parent()
			if parent.is_targetable(): #only check things that we can normally pick
				return area.get_parent()
	for area in areas:
		if area.get_name().find("Location") != -1: #the Locations have unique modifiers to their name because they're all children of one class
			if area.is_targetable():
				return area
	return null

func get_modifier_mock_hovered():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.get_name() == "ModifierCollisionArea": #hackey, since CollisionArea is the one that has monitorable enabled but ClickArea doesn't
			return area.get_parent()
