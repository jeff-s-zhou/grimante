
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var current_scene = null
var _params = null

var seen_units = {"Pawn":true, "Berserker":true, "Cavalier":true, 
"Archer": true, "Corsair": true, "Saint":true, "Assassin":true, "Pyromancer":true, "Frost Knight": true}
var seen_effect = {}

var PLATFORMS = {"Android":1, "iOS":2, "PC":3} 

var platform = PLATFORMS.PC


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	
func goto_scene(path, params=null):
	call_deferred("_deferred_goto_scene", path, params)


func _deferred_goto_scene(path, params):
	_params = params
	current_scene.free()
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	
	get_tree().set_current_scene( current_scene )

func get_param(name):
	if _params != null and _params.has(name):
		return _params[name]
	return null
	


