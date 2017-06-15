extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var grid

var currently_selected

const FinalHeroMockPiecePrototype = preload("res://UI/FinalHeroMockPiece.tscn")

var current_pos = 65

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var ArcherPiece = load("res://PlayerPieces/CavalierPiece.tscn").instance()
	initialize(ArcherPiece)
	initialize(ArcherPiece)
	initialize(ArcherPiece)
	initialize(ArcherPiece)
	initialize(ArcherPiece)

#the control flow is that it's passed to grid through initialize_piece in combat
#and then passed here?
func initialize(unused_piece):
	unused_piece.set_pos(Vector2(-999, -999)) #get it out of the way
	
	var mock_piece = FinalHeroMockPiecePrototype.instance()
	mock_piece.initialize(unused_piece)
	mock_piece.set_pos(Vector2(current_pos, 125))
	add_child(mock_piece)
	self.current_pos += 120
	
	
func select(piece):
	var coords = self.currently_selected.coords
	self.currently_selected.set_pos(Vector2(-999, -999))
	grid.remove_piece(self.currently_selected)
	self.currently_selected = piece
	grid.add_piece(coords, self.currently_selected)

	