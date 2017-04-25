extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Fortifier = preload("res://EnemyPieces/FortifierPiece.tscn")
const Grower = preload("res://EnemyPieces/GrowerPiece.tscn")
const Drummer = preload("res://EnemyPieces/DrummerPiece.tscn")
const Melee = preload("res://EnemyPieces/MeleePiece.tscn")
const Ranged = preload("res://EnemyPieces/RangedPiece.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2(73, 280))
	get_node("Grid").reset_deployable_indicators()
	
