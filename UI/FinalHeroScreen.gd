extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var grid = get_parent()

var currently_selected

signal final_hero_selected

const FinalHeroMockPiecePrototype = preload("res://UI/FinalHeroMockPiece.tscn")

var current_pos = 65

var pieces = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#the control flow is that it's passed to grid through initialize_piece in combat
#and then passed here?
func initialize(unused_piece):
	#we only show this screen if we have pieces to select lol
	self.pieces.append(unused_piece)
	unused_piece.set_pos(Vector2(-999, -999)) #get it out of the way
	
	var mock_piece = FinalHeroMockPiecePrototype.instance()
	mock_piece.initialize(unused_piece)
	mock_piece.set_pos(Vector2(current_pos, 125))
	add_child(mock_piece)
	self.current_pos += 120
	
	
func select(piece):
	var coords
	if self.currently_selected == null:
		coords = Vector2(3, 7)
	else:
		coords = self.currently_selected.coords
		self.currently_selected.set_pos(Vector2(-999, -999))
		get_parent().remove_piece(self.currently_selected)
	self.currently_selected = piece
	get_parent().add_piece(coords, self.currently_selected)
	self.hide()
	emit_signal("final_hero_selected")

func queue_free():
	for piece in self.pieces:
		if piece != self.currently_selected:
			piece.manual_free_cleanup()
			piece.free()
	.queue_free()
			
	