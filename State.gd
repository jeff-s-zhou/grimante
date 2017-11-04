extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var seen_units = {"Pawn":true}
var seen_effect = {}

var unit_roster = []
var level_set_data = {}
var user_info = {}
var current_level_set = null
var session_id = null #get a new one from server every time you go to a new level
var current_user = "Jeff"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	load_state()

func get_save_filename():
	return "user://" + self.current_user + ".save"

func load_state():
	var save = File.new()
	if !save.file_exists(get_save_filename()):
		request_user_id()
		print("no save file")
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
			print("loaded level set data: ", self.level_set_data)
		if state.has("user_info"):
			self.user_info = state["user_info"]
		if state.has("seen_units"):
			self.seen_units = state["seen_units"]
		else:
			request_user_id() #if there's no user_info, we need a user id
	save.close()

func save_state():
	var save = File.new()
	save.open(get_save_filename(), File.WRITE)
	
	#have to do this instead of store_line because loading bugs out on the last linebreak
	var save_data = {"user_info":user_info, "unit_roster":unit_roster, "level_set_data":level_set_data, "seen_units":seen_units}
	#TODO: might need to clear the file?
	save.store_string(save_data.to_json()) 
	save.close()
	
func add_to_roster(piece_filename):
	if !self.unit_roster.has(piece_filename):
		self.unit_roster.append(piece_filename)
	save_state()

func get_roster():
	return self.unit_roster
	
func set_seen(unit_name):
	self.seen_units[unit_name] = true
	save_state()
	

func get_level_score(level_set_id, level_id):
	if self.level_set_data.has(str(level_set_id)):
		var s = self.level_set_data[str(level_set_id)]
		if s.has(str(level_id)):
			return s[str(level_id)]
	return null
	
func save_level_progress(level_id, score):
	if self.current_level_set == null:
		return
		
	var current_level_set_id = str(self.current_level_set.id)
	level_id = str(level_id)
	
	if !self.level_set_data.has(current_level_set_id):
		self.level_set_data[current_level_set_id] = {}
	
	#ideally, this should be the same level set scored in self.level_set_data
	var level_set = self.level_set_data[current_level_set_id]
	
	if level_set.has(level_id):
		var existing_score = level_set[level_id]
		if score > existing_score:
			level_set[level_id] = score
	else:
		level_set[level_id] = score
		print("logging score in level_set: ", level_set)
	
	save_state()
	
	print(self.level_set_data)

func has_unlocked_boss_level():
	pass

func has_completed_level_set():
	pass


#USER_ID BUSINESS
func get_user_id():
	if self.user_info.has("user_id"):
		return self.user_info["user_id"]
	else:
		return null
		
func request_user_id():
	if get_node("/root/global").online_logging_flag:
		get_node("/root/HTTPHelper").request_new_user_id(0)
	
func set_user_id(id):
	self.user_info["user_id"] = id
	save_state()


#ATTEMPT SESSION ID BUSINESS
func get_attempt_session_id():
	if self.session_id != null:
		return self.session_id
	else:
		return null

#called whenever we start a new session of attempts
func request_attempt_session_id():
	if get_node("/root/global").online_logging_flag:
		self.session_id = null
		get_node("/root/HTTPHelper").request_new_attempt_session_id(0)
	
func set_attempt_session_id(id):
	self.session_id = id