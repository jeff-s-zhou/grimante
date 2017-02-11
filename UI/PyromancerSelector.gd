
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var tri_coords

signal is_targeted(location)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite").set_self_opacity(0.4)
	connect("mouse_enter", self, "_mouse_entered")
	connect("mouse_exit", self, "_mouse_exited")
	set_process_input(true)
	
func debug():
	pass
	
#set the position relative to the tri_coords
func triangulate_set_pos():
	var max_y = 0
	var min_y = 999999
	var max_x = 0
	var min_x = 999999
	for coords in tri_coords:
		var pos = get_parent().locations[coords].get_pos()
		if pos.x < min_x:
			min_x = pos.x
		if pos.x > max_x:
			max_x = pos.x
		if pos.y < min_y:
			min_y = pos.y
		if pos.y > max_y:
			max_y = pos.y
			
	var x = (max_x - min_x)/2 + min_x
	var y = (max_y - min_y)/2 + min_y
	set_pos(Vector2(x, y))
		
	
func reset_highlight():
	external_set_opacity(0.4)


func _mouse_entered():
	get_node("Sprite").set_self_opacity(1.0)
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	if get_parent().selected != null:
		get_parent().selected.predict(self.coords)

func _mouse_exited():
	get_node("Sprite").set_self_opacity(0.4)
	if get_parent().selected != null:
		get_parent().reset_prediction()
	
func _input_event(viewport, event, shape_idx):
	if event.is_action("select") and event.is_pressed():
		get_parent().set_target(self)

func input_event(event):
	if event.is_action("select") and event.is_pressed():
		get_parent().set_target(self)

func external_set_opacity(value=1.0):
	get_node("Sprite").set_self_opacity(value)
	
func get_size():
	return get_node("Sprite").get_item_rect().size
	