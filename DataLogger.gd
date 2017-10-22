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
	#log_online(self.stats.to_json())
	
func log_online(json_data):
	var HTTP = HTTPClient.new()
	var url = "/IQMcZufUb8e4mArWuTsa"
	var RESPONSE = HTTP.connect("http://www.putsreq.com",80)
	assert(RESPONSE == OK)
	
	while(HTTP.get_status() == HTTPClient.STATUS_CONNECTING or HTTP.get_status() == HTTPClient.STATUS_RESOLVING):
		HTTP.poll()
		OS.delay_msec(300)
	
	assert(HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
	var QUERY = json_data
	var HEADERS = ["User-Agent: Jeff", "Content-Type: application/json"]
	RESPONSE = HTTP.request(HTTPClient.METHOD_POST, url, HEADERS, QUERY)
	assert(RESPONSE == OK)
	
	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		OS.delay_msec(300)
	#    # Make sure request finished
	assert(HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED)

