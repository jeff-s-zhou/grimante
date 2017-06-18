extends Node

var stats = {}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize_level_stats(level_name):
	if !stats.has(level_name):
		stats[level_name] = {"attempts":0, "restarts":0, "restart_turn":[], "losses":0, "lose_turn":[], "wins":0, "win_turn":[]}
	
func log_attempt(level_name):
	initialize_level_stats(level_name)
	stats[level_name].attempts += 1
	save_state()
	
func log_restart(level_name, turn_restarted):
	initialize_level_stats(level_name)
	stats[level_name].restarts += 1
	stats[level_name].restart_turn.append(turn_restarted)
	save_state()

func log_lose(level_name, turn_lost):
	initialize_level_stats(level_name)
	stats[level_name].losses += 1
	stats[level_name].lose_turn.append(turn_lost)
	save_state()

func log_win(level_name, turn_won):
	initialize_level_stats(level_name)
	stats[level_name].wins += 1
	stats[level_name].win_turn.append(turn_won)
	save_state()

func save_state():
	var save = File.new()
	save.open("user://stats.save", File.WRITE)
	#have to do this instead of store_line because loading bugs out on the last linebreak
	save.store_string(self.stats.to_json()) 
	save.close()


func load_state():
	var save = File.new()
	if !save.file_exists("user://stats.save"):
		return #Error!  We don't have a save to load
	
	# dict.parse_json() requires a declared dict.
	var current_line = {}
	# Load the file line by line
	save.open("user://stats.save", File.READ)
	
	while (!save.eof_reached()):
		current_line.parse_json(save.get_line())
		self.stats = current_line
	save.close()