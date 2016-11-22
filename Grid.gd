
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var locations = {}
var pieces = {}


#starts at 1, 2, 2, 3, 3, 4, 4, 5, 5,
#ends at 8, 8, 9, 9, 10, 10, 11, 11, 12

#in order, (0, 8), (1, 8), (1, 9), (2, 9), (2, 10), (3, 10), (3, 11), (4, 11), (4, 12)

const _GRID_X_OFFSET = -400
const _GRID_Y_OFFSET = -400

const TILE_X_OFFSET = 5
const TILE_Y_OFFSET = 29

const _Z_PIECE_OFFSET = Vector2(0, -0) #this is to offset for the pseudo-3d vertical distance of pieces

const _LOCATION_Y_OFFSETS = [0, 0, 1, 1, 2, 2, 3, 3, 4]

var current_location

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var location = load("res://Location.tscn")
	
	# place location tiles
	for i in range(0, 9):
		var offset = 0
		var column_count = 8
		if i % 2 == 1:
			offset = -52
			column_count = 9
		for j in range(0, column_count):
			var location1 = location.instance()
			var tile_x_spacing = location1.get_size().width + TILE_X_OFFSET
			var tile_y_spacing = location1.get_size().height + TILE_Y_OFFSET
			location1.set_pos(Vector2(_GRID_X_OFFSET + tile_x_spacing * i, _GRID_Y_OFFSET + offset + (tile_y_spacing * j)))
			location1.connect("location_is", self, "set_current_location")
			add_child(location1)
			
			var location_y_coord = _LOCATION_Y_OFFSETS[i] + j
			locations[Vector2(i, location_y_coord)] = location1
			location1.set_coords(Vector2(i, location_y_coord))


#so we know what location the player is currently hovering over
func set_current_location(location):
	self.current_location = location
	
func add_piece(coords, piece):
	pieces[coords] = piece
	piece.coords = coords
	var location = locations[coords]
	piece.set_pos(location.get_pos() + _Z_PIECE_OFFSET)
	add_child(piece)

#moves the piece's location on grid. doesn't actually physically move the sprite
func move_piece(old_coords, new_coords):
	var piece = pieces[old_coords]
	pieces.erase(old_coords)
	pieces[new_coords] = piece
	

#will return a piece if there is a piece, otherwise the location
func get_at_location(coords):
	if pieces.has(coords):
		return pieces[coords]
	elif locations.has(coords):
		return locations[coords]
	else:
		return null
	
#done once a piece is moved by the player	
func reset_highlighting():
	for location in locations.values():
		location.unhighlight()
	for piece in pieces.values():
		piece.unhighlight()

#direction goes from 0-5, clockwise from top
#magnitude is 1 indexed
func get_neighbors(coords, magnitude_range=[1, 2], direction_range=[0, 6]):
	var return_set = [] #make this a dict?
	var change_vector = Vector2(0, 0)
	for direction in range(direction_range[0], direction_range[1]):
		if direction == 0:
			change_vector = Vector2(0, -1)
		elif direction == 1:
			change_vector = Vector2(1, 0)
		elif direction == 2:
			change_vector = Vector2(1, 1)
		elif direction == 3:
			change_vector = Vector2(0, 1)
		elif direction == 4:
			change_vector = Vector2(-1, 0)
		elif direction == 5:
			change_vector = Vector2(-1, -1)
			
		for i in range(magnitude_range[0], magnitude_range[1]):
			var new_coords = coords + i * change_vector
			var neighbor = get_at_location(new_coords)
			if neighbor:
				return_set.append(neighbor)
			
	return return_set

#gets the "diagonal" neighbors in the six directions
func get_diagonal_neighbors(coords, magnitude_range=[1, 2], direction_range=[0, 6]):
	var return_set = [] #make this a dict?
	var change_vector = Vector2(0, 0)
	for direction in range(direction_range[0], direction_range[1]):
		if direction == 0:
			change_vector = Vector2(1, -1)
		elif direction == 1:
			change_vector = Vector2(2, 1)
		elif direction == 2:
			change_vector = Vector2(1, 2)
		elif direction == 3:
			change_vector = Vector2(-1, 1)
		elif direction == 4:
			change_vector = Vector2(-2, -1)
		elif direction == 5:
			change_vector = Vector2(-1, -2)
			
		for i in range(magnitude_range[0], magnitude_range[1]):
			var new_coords = coords + i * change_vector
			var neighbor = get_at_location(new_coords)
			if neighbor:
				return_set.append(neighbor)
			
	return return_set

#calls both get_neighbors and get_diagonal_neighbors to provide a radial
#TODO: broken with a radius 3 because hexagons. fix in case I ever need
func get_radial_neighbors(coords, radial_range=[1, 3]):
	var diagonal_radial_range = [radial_range[0], radial_range[1] - 1]
	return get_neighbors(coords, radial_range) + get_diagonal_neighbors(coords, diagonal_radial_range)


	
static func hex_normalize(vector):
	if(vector.x == 0 or vector.y == 0):
		return vector.normalized()
	else:
		var lowest_denominator = abs(vector.x)
		if(vector.y < vector.x):
			lowest_denominator = abs(vector.y)
		return Vector2(vector.x/lowest_denominator, vector.y/lowest_denominator)

#utility function for enemy unit deployment
func get_top_of_column(column):
	return Vector2(column, _LOCATION_Y_OFFSETS[column])


#utility function for player unit deployment
func get_bottom_of_column(column):
	var column_count = 8
	if column % 2 == 1:
		column_count = 9
			
	return Vector2(column, _LOCATION_Y_OFFSETS[column] + column_count - 1)





