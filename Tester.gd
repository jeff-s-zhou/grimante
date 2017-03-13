extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal test_signal1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	print(get_radial_range(Vector2(0, 0), [1, 1]))
	
func cube_to_hex(h): # axial
	print("in cube to hex")
	print(h)
	return Vector2(h.x, -h.y)


func get_radial_range(coords, radial_range=[1, 3]):
	var n = radial_range[1]
	var results = []
	for x in range(-n, n + 1):
		for y in range(max(-n, -x - n), min(n, -x + n) + 1): 
			var z = -x - y 
			results.append(coords + cube_to_hex(Vector3(x, y, z)))
	return results
			