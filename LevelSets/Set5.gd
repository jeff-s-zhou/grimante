extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_set():
	return Set.new(5, "Fifth",
	[corsair_trials(), corsair_drive(), ghostbusters(), ghostbusters2(), boss_fight(), fray(), big_boss_fight()], 
	[fray(true), big_boss_fight(true)])

func corsair_trials():
	var tutorial = load("res://Tutorials/corsair_trial.gd").new()
	var flags = ["no_stars", "no_inspire", "hints"]
	var base_id = 10013
	var challenges = []
	for i in range(1, 6):
		var trial_hint = funcref(tutorial, "get_trial" + str(i) + "_hints")
		var extras = {"free_deploy":false, "tutorial":trial_hint, "flags":flags}
		var pieces = load_level("corsair_trial" + str(i) +".level")
		var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
		var heroes = pieces[1]
		var challenge = LevelTypes.Timed.new(base_id + i, "", heroes, enemies, 1, null, extras) 
		challenges.append(challenge)
	return LevelTypes.Trial.new(00022, "Corsair Trials", challenges)

	
func corsair_drive():
	var pieces = load_level("corsair_drive.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new(00024, "Corsair Drive", allies, enemies, 4, null, extras)
	
func ghostbusters():
	var pieces = load_level("ghostbusters.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new(00025, "Ghostbusters", allies, enemies, 3, null, extras)
	
func ghostbusters2():
	var pieces = load_level("ghostbusters2.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire"]
	var extras = {"flags":flags, "free_deploy":true}
	return LevelTypes.Timed.new(00026, "Ghostbusters 2", allies, enemies, 4, null, extras)
	
func boss_fight():
	var pieces = load_level("boss_fight.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var tutorial = load("res://Tutorials/boss_fight.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"tutorial":tutorial_func, "flags":flags, "free_deploy":false}

	return LevelTypes.Timed.new(00027, "Boss Fight", allies, enemies, 3, null, extras)
	
func fray(hard=false):
	var pieces
	if hard:
		pieces = load_level("fray_hard.level")
	else:
		pieces = load_level("fray.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}

	return LevelTypes.Timed.new(00028, "Fray", allies, enemies, 4, null, extras)

	
func big_boss_fight(hard=false):
	var pieces
	if hard:
		pieces = load_level("big_boss_fight_hard.level")
	else:
		pieces = load_level("big_boss_fight.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire"]
	var extras = {"flags":flags, "free_deploy":true}
	return LevelTypes.Timed.new(00029, "Bigger Boss Fight", allies, enemies, 3, null, extras)