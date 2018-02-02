extends Node

var level_start_time

const ATTEMPT_TYPES = {"lose":-1, "restart":0, "win":1}

const FILE_NAME_FORMAT = "%s %s_%s %s_%s"
var file_name = ""

const URL = "http://www.putsreq.com"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var time = OS.get_datetime()
	self.file_name = FILE_NAME_FORMAT % [time.year, time.month, time.day, time.hour, time.minute]
	
func log_start_attempt(level_id):
	self.level_start_time = OS.get_unix_time()

func log_attempt_helper(level_id, attempt_type, turn):
	var time_now = OS.get_unix_time()
	var elapsed = time_now - self.level_start_time
	var user_id = get_node("/root/State").get_user_id()
	var attempt_session_id = get_node("/root/State").get_attempt_session_id()
	print("calling the log_attempt helper with this session_id: ", attempt_session_id)
	var version = get_node("/root/global").get_version()
	#these need to have already been grabbed from the server, otherwise there's a problem
	if user_id != null and attempt_session_id != null:
		var attempt = {"attempt_session_id":attempt_session_id, "user_id":user_id, "version":version, 
		"level_id":level_id, "seconds":elapsed, "final_turn":turn, "outcome":attempt_type}
		return attempt
	else:
		print("there's no user_id or there's no attempt_session_id, can't log attempt")
		return null

func log_restart(level_id, turn):
	var attempt = log_attempt_helper(level_id, ATTEMPT_TYPES.restart, turn)
	log_online(attempt)

func log_lose(level_id, turn):
	var attempt = log_attempt_helper(level_id, ATTEMPT_TYPES.lose, turn)
	log_online(attempt)

func log_win(level_id, turn):
	var attempt = log_attempt_helper(level_id, ATTEMPT_TYPES.win, turn)
	log_online(attempt)

func save_state(attempt):
	var save = File.new()
	save.open("user://" + self.file_name + ".save", File.WRITE)
	#have to do this instead of store_line because loading bugs out on the last linebreak
	if attempt != null:
		save.store_string(attempt.to_json()) 
		save.close()
		
func log_online(attempt):
	if get_node("/root/global").online_logging_flag and attempt != null:
		get_node("/root/HTTPHelper").log_online(attempt.to_json())
	
	
