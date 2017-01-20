
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	
	
	
func _input(ev):
   if (ev.type==InputEvent.MOUSE_MOTION):
       set_pos(ev.pos)

	
func get_piece_hovered():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.get_name() == "CollisionArea": #hackey, since CollisionArea is the one that has monitorable enabled but ClickArea doesn't
			return area.get_parent()
	return null
	
