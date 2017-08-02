extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var piece

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(piece):
	get_node("Sprite").set_texture(piece.get_sprite())
	self.piece = piece

#this is wrong, find the proper arguments in a sec
func _input(event):
	get_parent().select(self.piece)
	
	
func _input_event(viewport, event, shape_idx):
	if get_node("InputHandler").is_select(event):
		get_parent().select(self.piece)