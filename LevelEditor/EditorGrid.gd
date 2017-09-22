extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var locations = {}
var pieces = {}

var shadow_wall_tile_range = []
var shifting_sands_tiles = []

var total_hp = 0

#starts at 1, 2, 2, 3, 3, 4, 4, 5, 5,
#ends at 8, 8, 9, 9, 10, 10, 11, 11, 12

#in order, (0, 8), (1, 8), (1, 9), (2, 9), (2, 10), (3, 10), (3, 11), (4, 11), (4, 12)

var tiles_x = 7 #x
var tiles_y = 6 #y

const _GRID_X_OFFSET = 0
const _GRID_Y_OFFSET = 0

#const TILE_X_OFFSET = -16
const TILE_X_OFFSET = -5
#const TILE_Y_OFFSET = 8
const TILE_Y_OFFSET = 20

const _Z_PIECE_OFFSET = Vector2(0, -0) #this is to offset for the pseudo-3d vertical distance of pieces

const _LOCATION_Y_OFFSETS = [0, 0, 1, 1, 2, 2, 3]

var furthest_back_coords = Vector2(0, 0) #initialized to this because it's at the top of the map

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var location = load("res://LevelEditor/EditorLocation.tscn")

	# place location tiles
	for i in range(0, self.tiles_x):
		var offset = 0
		var column_count = self.tiles_y 
		if i % 2 == 1:
			#offset = -44
			offset = -50
			column_count = self.tiles_y + 1
		for j in range(0, column_count):
			var location1 = location.instance()
			var tile_x_spacing = location1.get_size().width + TILE_X_OFFSET
			var tile_y_spacing = location1.get_size().height + TILE_Y_OFFSET
			location1.set_pos(Vector2(_GRID_X_OFFSET + tile_x_spacing * i, _GRID_Y_OFFSET + offset + (tile_y_spacing * j)))
			add_child(location1)
			
			var location_y_coord = _LOCATION_Y_OFFSETS[i] + j
			self.locations[Vector2(i, location_y_coord)] = location1
			location1.set_coords(Vector2(i, location_y_coord))
			
			
func update_total_hp():
	get_node("Label").set_text("Wave HP: " + str(self.total_hp))
	
			
func add_piece(name, turn, coords, piece, hp, modifiers=null):
	add_child(piece)
	piece.initialize(name, turn, coords, hp, modifiers)
	pieces[coords] = piece
	locations[coords].set_pickable(false)
	self.total_hp += int(hp)
	update_total_hp()
	
func add_hero_piece(name, turn, coords, piece):
	add_child(piece)
	piece.initialize(name, turn, coords)
	pieces[coords] = piece
	locations[coords].set_pickable(false)
	
func remove_piece(coords):
	if !self.pieces[coords].is_hero:
		self.total_hp -= int(self.pieces[coords].hp)
		update_total_hp()
	self.pieces.erase(coords)
	locations[coords].set_pickable(true)

func swap_pieces(coords1, coords2):
	var temp = self.pieces[coords1]
	self.pieces[coords1] = self.pieces[coords2]
	self.pieces[coords2] = temp

#moves the piece's location on grid. doesn't actually physically move the sprite
func move_piece(old_coords, new_coords):
	locations[old_coords].set_pickable(true)
	var piece = self.pieces[old_coords]
	self.pieces.erase(old_coords)
	self.pieces[new_coords] = piece
	locations[new_coords].set_pickable(false)
	
func invalid_move():
	pass