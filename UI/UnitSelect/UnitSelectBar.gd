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
const Knight = preload("res://PlayerPieces/KnightPiece.tscn")
const Assassin = preload("res://PlayerPieces/AssassinPiece.tscn")
const Stormdancer = preload("res://PlayerPieces/StormdancerPiece.tscn")
const Pyromancer = preload("res://PlayerPieces/PyromancerPiece.tscn")
const FrostKnight = preload("res://PlayerPieces/FrostKnightPiece.tscn")
const Saint = preload("res://PlayerPieces/SaintPiece.tscn")
const Corsair = preload("res://PlayerPieces/CorsairPiece.tscn")

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
		location.set_pos(Vector2(x_width * i + 106, 60)) 


func handle_arrow_input(event, name):
	if get_node("InputHandler").is_select(event):
		if name == "LeftArrow":
			self.shift_amount = -4.0
		elif name == "RightArrow":
			self.shift_amount = 4.0
		set_process(true)
	elif get_node("InputHandler").is_unpress(event):
		set_process(false)


func _process(delta):
	shift()
			

func shift():
	for key in self.locations.keys():
		self.locations[key].translate(Vector2(self.shift_amount, 0))
	for key in self.pieces.keys():
		self.pieces[key].translate(Vector2(self.shift_amount, 0))
		

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
		