
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

var current_scene = null
var _params = null

var seen_units = {"Pawn":true}

var seen_effect = {}

var available_unit_roster = {}

#var full_unit_roster = ["Berserker", "Corsair", "Archer", "Saint", "Assassin", "Pyromancer", "Stormdancer", "Cavalier"]


var PLATFORMS = {"Android":1, "iOS":2, "PC":3} 

var platform = PLATFORMS.PC

var combat_resource


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	
	if self.platform == PLATFORMS.PC:
		combat_resource = "res://DesktopCombat.tscn"
	else:
		combat_resource = "res://Combat.tscn"
	
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
	

func save_state():
	var first_line = true
	var save = File.new()
	save.open("user://state.save", File.WRITE)
	for unit_prototype in available_unit_roster.keys():
		var unit = unit_prototype.instance()
		var file_name = unit.get_filename()
		unit.free()
		
		#have to do this instead of store_line because loading bugs out on the last linebreak
		if first_line:
			first_line = false
		else:
			save.store_string("\n")
		save.store_string(file_name) 
		
	save.close()
	

func load_state():
	var save = File.new()
	if !save.file_exists("user://state.save"):
		return #Error!  We don't have a save to load

	# Load the file line by line
	save.open("user://state.save", File.READ)
	while (!save.eof_reached()):
		var file_name = save.get_line()
		# First we need to create the object and add it to the tree and set its position.
		var prototype = load(file_name)
		available_unit_roster[prototype] = true
	save.close()
	
#

