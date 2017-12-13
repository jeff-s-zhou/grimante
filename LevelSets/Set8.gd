extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func get_set():
	return Set.new(8, "Eighth",
	[saint_trials(), saint_practice()], [])

func saint_trials():
	var tutorial = load("res://Tutorials/saint_trial.gd").new()
	var flags = ["hints, inspire"]
	var challenges = []
	var base_id = 10030
	for i in range(1, 4):
		var trial_hint = funcref(tutorial, "get_trial" + str(i) + "_hints")
		var extras = {"free_deploy":false, "tutorial":trial_hint, "flags":flags}
		var pieces = load_level("saint_trial" + str(i) +".level")
		var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
		var heroes = pieces[1]
		var challenge = LevelTypes.Timed.new(base_id + i, "", heroes, enemies, 1, null, extras) 
		challenges.append(challenge)
	return LevelTypes.Trial.new(00045, "Saint Trials", challenges)
	
func saint_practice():
	var pieces
	var score_guide
	pieces = load_level("saint_drive.level")
	score_guide = {1:5, 2:5, 3:5, 4:4} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00046, "Saint Drive", allies, enemies, 4, null, extras)
