extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var pieces = {}

var locations = {}

var location_prototype = preload("res://Location.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#var roster = get_node("/root/constants").player_roster
	var x_width = 106
	
	for i in range(0, 9):
		var location = location_prototype.instance()
		add_child(location)
		var coords = Vector2(i, 99)
		self.locations[coords] = location
		location.set_coords(coords)
		location.set_pos(Vector2(x_width * i, 45)) 
		