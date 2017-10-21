extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var seen_units = {"Pawn":true}
var seen_effect = {}

var unit_roster = []
var level_set_data = {}
var current_level_set = null
var current_user = "Jeff"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	load_state()
	print("initialized in State")

func get_save_filename():
	return "user://" + self.current_user + ".save"

func load_state():
	var save = File.new()
	if !save.file_exists(get_save_filename()):
		return #Error!  We don't have a save to load
	
	# dict.parse_json() requires a declared dict.
	var current_line = {}
	# Load the file line by line
	save.open(get_save_filename(), File.READ)
	
	while (!save.eof_reached()):
		current_line.parse_json(save.get_line())
		var state = current_line
		if state.has("unit_roster"):
			self.unit_roster = state["unit_roster"]
		if state.has("level_set_data"):
			self.level_set_data = state["level_set_data"]
	save.close()

func save_state():
	var save = File.new()
	save.open(get_save_filename(), File.WRITE)
	
	#have to do this instead of store_line because loading bugs out on the last linebreak
	var save_data = {"unit_roster":unit_roster, "level_set_data":level_set_data}
	#TODO: might need to clear the file?
	save.store_string(save_data.to_json()) 
	save.close()
	
func add_to_roster(piece_filename):
	if !self.unit_roster.has(piece_filename):
		self.unit_roster.append(piece_filename)
	save_state()

func get_roster():
	return self.unit_roster
	
func get_level_set_data(level_set_id):
	if self.level_set_data.has(level_set_id):
		return self.level_set_data[level_set_id]
	else:
		return null
	
func save_level_progress(level_id, score):
	if !self.level_set_data.has(self.current_level_set.id):
		self.level_set_data[self.current_level_set.id] = {}
	
	#ideally, this should be the same level set scored in self.level_set_data
	var level_set = self.level_set_data[self.current_level_set.id]
	
	if level_set.has(level_id):
		var existing_score = level_set[level_id]
		if greater_than(score, existing_score):
			level_set[level_id] = score
	else:
		level_set[level_id] = score
	
	save_state()
			
func greater_than(score, existing_score):
	var score_values = {"S+":5, "S":4, "A":3, "B":2, "C":1, "F":0}
	return score_values[score] > score_values[existing_score]


func has_unlocked_boss_level():
	pass

func has_completed_level_set():
	pass