extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var active = false

var running = false

var restart_count = 0
var attempt_count = 0
var level_id = 0 #we use this to keep track of if they're restarting on same level and stuff

var trial_ids = [1, 2, 3, 4, 5, 8,
10004, 10007, 10013, 10018, 10022, 10034, 10025, 10039] #we use these to make sure we can't trigger some achievements during trials

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(level_id):
	if !self.running:
		Steam.steamInit()
		self.running = true
		print("Steam initialized")
	
	
	self.active = true
	Steam.requestCurrentStats()
	
	if !level_id == self.level_id: #we've switched levels/moved on
		self.level_id = level_id
		self.restart_count = 0
		self.attempt_count = 0
	
	var smash = Steam.getAchievement("SMASH")
	if !smash:
		print("connecting smash")
		get_node("/root/Combat").connect("ach_smash", self, "set_smash")
	get_node("/root/Combat").connect("restart", self, "count_restarts")
	get_node("/root/Combat").connect("restart", self, "count_attempts")
	get_node("/root/Combat").connect("loss", self, "count_attempts")
	get_node("/root/Combat").connect("ach_clutch", self, "set_clutch")

	
func count_restarts():
	self.restart_count += 1
	if self.restart_count == 8:
		set_achievement("PERFECTIONIST")
		
func count_attempts():
	self.attempt_count += 1

func set_smash():
	set_achievement("SMASH")
	get_node("/root/Combat").disconnect("ach_smash", self, "set_smash")

func set_clutch():
	if !(self.level_id in self.trial_ids):
		set_achievement("CLUTCH")
	
func set_assassin_bloodlust():
	if !(self.level_id in self.trial_ids):
		set_achievement("BLOODLUST")
		
func set_stormdancer_perfect_storm():
	if !(self.level_id in self.trial_ids):
		set_achievement("PERFECT_STORM")

func set_saint_infinite_light():
	if !(self.level_id in self.trial_ids):
		set_achievement("INFINITE_LIGHT")
		
func set_what_do():
	if !(self.level_id in self.trial_ids):
		set_achievement("WHAT_DO")

#called directly
func set_level_complete(level_schematic, turn_count):
	var stars = get_node("/root/State").get_total_stars()
	set_stat("STARS", stars)
	
	var id = level_schematic.id
	if level_schematic.is_new_record(turn_count):
		set_achievement("WORLD_BEATER")
		
	if get_tree().get_nodes_in_group("player_pieces").size() == 1:
		set_achievement("SURVIVOR")
	
	if self.attempt_count >= 8:
		set_achievement("UNYIELDING")
	
	if id == 10004: #Archer Trials
		set_achievement("ARCHER")
	elif id == 10007: #Assassin Trials
		set_achievement("ASSASSIN")
	elif id == 10013: #Frost Knight Trials
		set_achievement("FROST_KNIGHT")
	elif id == 10018: #Corsair Trials
		set_achievement("CORSAIR")
	elif id == 10022: #Stormdancer Trials
		set_achievement("STORMDANCER")
	elif id == 10034: #Saint Trials
		set_achievement("SAINT")
	elif id == 53: #beat the final level
		set_achievement("THE_END")

func set_stat(name, value):
	if self.active:
		Steam.setStatInt(name, value)
		Steam.storeStats()
	
func set_achievement(name):
	if self.active:
		Steam.setAchievement(name)
		Steam.storeStats()