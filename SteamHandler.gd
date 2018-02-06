extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var active = false

var restart_count = 0
var attempt_count = 0
var level_id = 0 #we use this to keep track of if they're restarting on same level and stuff

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Steam.steamInit()
	
func initialize(level_id):
	print("Steam initialized")
	Steam.requestCurrentStats()
	
	if !level_id == self.level_id: #we've switched levels/moved on
		self.level_id = level_id
		self.restart_count = 0
		self.attempt_count = 0
	
	var smash = Steam.getAchievement("SMASH")
	if !smash:
		get_node("/root/Combat").connect("ach_smash", self, "set_smash")
	get_node("/root/Combat").connect("restart", self, "count_restarts")
	get_node("/root/Combat").connect("restart", self, "count_attempts")
	get_node("/root/Combat").connect("loss", self, "count_attempts")

	
func count_restarts():
	self.restart_count += 1
	if self.restart_count == 10:
		set_achievement("PERFECTIONIST")
		
func count_attempts():
	self.attempt_count += 1

func set_smash():
	print("setting smash")
	set_achievement("SMASH")
	get_node("/root/Combat").disconnect("ach_smash", self, "set_smash")

#called directly
func set_level_complete(level_schematic, turn_count):
	var stars = get_node("/root/State").get_total_stars()
	set_stat("STARS", stars)
	
	var id = level_schematic.id
	if level_schematic.is_new_record(turn_count):
		set_achievement("WORLD_BEATER")
	
	if self.attempt_count >= 10:
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