extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var seen_units = {"Pawn":true}
var seen_effect = {}

var unit_roster = []
var level_set_data = {}
var completed_level_sets = {}
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
		if state.has("completed_level_sets"):
			self.completed_level_sets = state["completed_level_sets"]
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
	var save_data = {"user_info":user_info, "unit_roster":unit_roster, 
	"level_set_data":level_set_data, "completed_level_sets": completed_level_sets, "seen_units":seen_units}
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


func is_set_unlocked(level_set_id):
	if level_set_id == 1: #first set is unlocked
		return true
#	print("is set unlocked: ", level_set_id)
#	print(self.completed_level_sets.keys())
	var previous_set_id = level_set_id - 1
	return (previous_set_id in self.completed_level_sets.keys() or str(previous_set_id) in self.completed_level_sets.keys())
	
func is_set_completed(level_set=null):
	if level_set == null:
		level_set = self.current_level_set
	return str(level_set.id) in self.completed_level_sets.keys() or level_set.id in self.completed_level_sets.keys()
	
func get_level_set_progress(level_set=null):
	if level_set == null:
		level_set = self.current_level_set
	var level_set_id = level_set.id
	if !self.level_set_data.has(str(level_set_id)): #if there's nothing, it's 0/x levels
		return [0, level_set.get_level_count()]
		
	var s = self.level_set_data[str(level_set_id)]
	var completed = 0
	for level_id in s.keys():
		if s.has(level_id) and s[level_id] != 0: #if attempted and succeeded
			completed += 1
	return [completed, level_set.get_level_count()]
	

func get_stars(level_set=null):
	if level_set == null:
		level_set = self.current_level_set
	var level_set_id = level_set.id
	if !self.level_set_data.has(str(level_set_id)): #if there's nothing, obvs no full cleared
		return [0, level_set.get_level_count() * 5]
		
	var s = self.level_set_data[str(level_set_id)]
	var stars = 0
	for level_id in s.keys():
		stars += s[level_id]
	
	print(str(stars) + "/" + str(level_set.get_level_count() * 5))
	return [stars, level_set.get_level_count() * 5]


func get_level_score(level_id, level_set_id=null):
	if level_set_id == null and self.current_level_set == null:
		return
		
	if level_set_id == null:
		level_set_id = self.current_level_set.id
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
		
	#separate structure to keep track of completed level sets
	var progress = get_level_set_progress(self.current_level_set) 
	if progress[0] == progress[1]:
		set_completed_level_set(self.current_level_set.id)
	
	save_state()


func set_completed_level_set(id):
	self.completed_level_sets[str(id)] = true
	save_state()

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