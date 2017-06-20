extends Node

var stats = {}

var level_start_time

const ATTEMPT_TYPES = {"lose":"lose", "restart":"restart", "win":"win"}

const FILE_NAME_FORMAT = "%s %s_%s %s_%s"
var file_name = ""

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var time = OS.get_datetime()
	self.file_name = FILE_NAME_FORMAT % [time.year, time.month, time.day, time.hour, time.minute]


func initialize_level_stats(level_name):
	if !stats.has(level_name):
		stats[level_name] = {"attempts_count":0, "attempts":[]}
	
func log_start_attempt(level_name):
	self.level_start_time = OS.get_unix_time()
	initialize_level_stats(level_name)
	stats[level_name].attempts_count += 1
	save_state()

func log_attempt_helper(level_name, attempt_type, turn):
	var time_now = OS.get_unix_time()
	var elapsed = time_now - self.level_start_time
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02dm %02ds" % [minutes, seconds]
	var attempt = {"type":attempt_type, "turn":turn, "time":str_elapsed}
	self.stats[level_name].attempts.append(attempt)

	
func log_restart(level_name, turn):
	initialize_level_stats(level_name)
	log_attempt_helper(level_name, ATTEMPT_TYPES.restart, turn)
	save_state()

func log_lose(level_name, turn):
	initialize_level_stats(level_name)
	log_attempt_helper(level_name, ATTEMPT_TYPES.lose, turn)
	save_state()

func log_win(level_name, turn):
	initialize_level_stats(level_name)
	log_attempt_helper(level_name, ATTEMPT_TYPES.win, turn)
	save_state()

func save_state():
	var save = File.new()
	save.open("user://" + self.file_name + ".save", File.WRITE)
	#have to do this instead of store_line because loading bugs out on the last linebreak
	save.store_string(self.stats.to_json()) 
	save.close()


#func load_state():
#	var save = File.new()
#	if !save.file_exists("user://stats.save"):
#		return #Error!  We don't have a save to load
#	
#	# dict.parse_json() requires a declared dict.
#	var current_line = {}
#	# Load the file line by line
#	save.open("user://stats.save", File.READ)
#	
#	while (!save.eof_reached()):
#		current_line.parse_json(save.get_line())
#		self.stats = current_line
#	save.close()