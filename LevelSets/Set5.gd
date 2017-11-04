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
	var score_guide = {1:5, 2:5, 3:5, 4:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false, "score_guide":score_guide}
	return LevelTypes.Timed.new(00024, "Corsair Drive", allies, enemies, 4, null, extras)
	
	
func football():
	var pieces = load_level("football.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new(00023, "Football", allies, enemies, 3, null, extras)
	
func ghostbusters():
	var pieces = load_level("ghostbusters.level")
	var score_guide = {1:5, 2:5, 3:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false, "score_guide":score_guide}
	return LevelTypes.Timed.new(00025, "Ghostbusters", allies, enemies, 3, null, extras)

#probably too hard
func ghostbusters2():
	var pieces = load_level("ghostbusters2.level")
	var score_guide = {1:5, 2:5, 3:4, 4:4, 5:3} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/ghostbusters2.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire"]
	var extras = {"flags":flags, "free_deploy":true, "tutorial":tutorial_func, "score_guide":score_guide}
	return LevelTypes.Timed.new(00026, "Ghostbusters 2", allies, enemies, 5, null, extras)

#pseudo tutorial, can just give 5 stars
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
	var score_guide
	if hard:
		pieces = load_level("fray_hard.level")
		score_guide = {1:5, 2:5, 3:5, 4:4} #not tested
	else:
		pieces = load_level("fray.level")
		score_guide = {1:5, 2:5, 3:5, 4:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false, "hard":hard, "score_guide":score_guide}

	return LevelTypes.Timed.new(00028, "Fray", allies, enemies, 4, null, extras)


#doesn't seem too hard?
func big_boss_fight(hard=false):
	var pieces
	var score_guide
	if hard:
		pieces = load_level("big_boss_fight_hard.level")
		score_guide = {1:5, 2:5, 3:4} #not tested
	else:
		pieces = load_level("big_boss_fight.level")
		score_guide = {1:5, 2:5, 3:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire"]
	var extras = {"flags":flags, "free_deploy":true, "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00029, "Bigger Boss Fight", allies, enemies, 3, null, extras)