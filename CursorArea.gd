
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


