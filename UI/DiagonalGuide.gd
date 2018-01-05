extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var resolution
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.resolution = get_node("/root/global").get_resolution()
	


func set_pos(position):
	get_node("Sprite").set_pos(position)
	get_node("Light2D").set_global_pos(Vector2(resolution.x/2, resolution.y/2 - 12))
	
	