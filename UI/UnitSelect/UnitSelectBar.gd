extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var shift_amount

var pieces = {}

var locations = {}

var location_prototype = preload("res://Location.tscn")

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")
const Cavalier = preload("res://PlayerPieces/CavalierPiece.tscn")
const Archer = preload("res://PlayerPieces/ArcherPiece.tscn")
const Assassin = preload("res://PlayerPieces/AssassinPiece.tscn")
const Stormdancer = preload("res://PlayerPieces/StormdancerPiece.tscn")
const Pyromancer = preload("res://PlayerPieces/PyromancerPiece.tscn")
const FrostKnight = preload("res://PlayerPieces/FrostKnightPiece.tscn")
const Saint = preload("res://PlayerPieces/SaintPiece.tscn")
const Corsair = preload("res://PlayerPieces/CorsairPiece.tscn")

const TILE_X_OFFSET = -5
const TILE_Y_OFFSET = 20

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
		
		var tile_x_spacing = location.get_size().width + TILE_X_OFFSET
		var tile_y_spacing = location.get_size().height + TILE_Y_OFFSET
		
		if i in range(0, 4):
			location.set_pos(Vector2(2 * tile_x_spacing * i, 0)) 
		elif i in range(4, 7):
			var x_coords = 2 * tile_x_spacing * (i - 4)
			location.set_pos(Vector2(x_coords + tile_x_spacing, 50))
		elif i in range(7, 9):
			location.set_pos(Vector2(2 * tile_x_spacing * (i - 6), tile_y_spacing))
		


func queue_free():
	for coords in self.pieces:
		self.pieces[coords].delete_from_bar()
	.queue_free()
		

#both are called from the Locations init'd on the bar. not used 
func predict(coords):
	pass
	
func reset_prediction():
	pass
	
func set_target(target):
	get_parent().set_target(target)
		