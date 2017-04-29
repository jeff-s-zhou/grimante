extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var coords

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite").set_self_opacity(0.4)

func get_size():
	return get_node("Sprite").get_item_rect().size
	
func set_coords(coords):
	self.coords = coords
	
func input_event(event):
	get_node("/root/LevelEditor").set_target(self)
