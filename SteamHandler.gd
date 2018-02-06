extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	Steam.steamInit()
	Steam.requestCurrentStats()
	init_achievements()
	
	
func init_achievements():
	var smash = Steam.getAchievement("SMASH")
	if !smash:
		get_node("/root/Combat").connect("ach_smash", self, "set_smash")
	get_node("/root/Combat").connect("ach_level_complete", self, "set_level_complete")

func set_smash():
	set_achievement("SMASH")
	get_node("/root/Combat").disconnect("ach_smash", self, "set_smash")
	
func set_level_complete(id):
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
	Steam.setStatInt(name, value)
	Steam.storeStats()
	
func set_achievement(name):
	Steam.setAchievement(name)
	Steam.storeStats()