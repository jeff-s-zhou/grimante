extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func get_set():
	return Set.new(7, "Seventh",
	[stormdancer_trials(), stormdancer_practice()], [stormdancer_practice(true)])

func stormdancer_trials():
	var tutorial = load("res://Tutorials/stormdancer_trial.gd").new()
	var flags = ["hints"]
	var challenges = []
	var base_id = 10018
	for i in range(1, 4):
		var trial_hint = funcref(tutorial, "get_trial" + str(i) + "_hints")
		var extras = {"free_deploy":false, "tutorial":trial_hint, "flags":flags}
		var pieces = load_level("stormdancer_trial" + str(i) +".level")
		var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
		var heroes = pieces[1]
		var challenge = LevelTypes.Timed.new(base_id + i, "", heroes, enemies, 1, null, extras) 
		challenges.append(challenge)
		
	var extras = {"free_deploy":false, "flags":flags}
	var pieces = load_level("stormdancer_trial4.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
	var heroes = pieces[1]
	var challenge = LevelTypes.Timed.new(10022, "", heroes, enemies, 1, null, extras) 
	challenges.append(challenge)
	
	
	return LevelTypes.Trial.new(00036, "Stormdancer Trials", challenges)
	
func stormdancer_practice(hard=false):
	var pieces
	if hard:
		pieces = load_level("stormdancer_practice_hard.level")
	else:
		pieces = load_level("stormdancer_practice.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[]}
	return LevelTypes.Timed.new(00037, "Stormdancer Drive", allies, enemies, 4, null, extras)
