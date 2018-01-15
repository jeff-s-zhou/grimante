extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func get_set():
	return Set.new(6, "Sixth",
	[inspire_trials(), inspire(), unstable(), fray2(), griffon(), defuse_the_bomb(), ghost_boss()], 
	[])


func inspire_trials():
	var tutorial = load("res://Tutorials/inspire_trial.gd").new()
	var flags = ["hints", "no_stars"]
	var base_id = 10034
	var challenges = []
	for i in range(1, 6):
		var trial_hint = funcref(tutorial, "get_trial" + str(i) + "_hints")
		var extras = {"free_deploy":false, "tutorial":trial_hint, "flags":flags}
		var pieces = load_level("inspire_trial" + str(i) +".level")
		var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
		var heroes = pieces[1]
		var turns = 1
		if i == 5:
			turns = 2
		var challenge = LevelTypes.Timed.new(base_id + i, "Inspire Trial " + str(i), heroes, enemies, turns, null, extras) 
		challenges.append(challenge)
	return LevelTypes.Trial.new(10039, "Inspire Trials", challenges)


func inspire(hard=false):
	var pieces
	var score_guide
	pieces = load_level("shield_inspire.level")
	score_guide = {1:5, 2:5, 3:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags, "score_guide":score_guide}
	return LevelTypes.Timed.new(00031, "Power of Friendship", allies, enemies, 3, null, extras)


func unstable(hard=false):
	var pieces
	var score_guide
	pieces = load_level("unstable.level")
	#score_guide = {1:5, 2:5, 3:5, 4:4, 5:3}
	score_guide = {1:5, 2:5, 3:4, 4:3}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags, "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00032, "Boom", allies, enemies, 4, null, extras)


func fray2(hard=false):
	var pieces
	var score_guide
	pieces = load_level("fray2.level")
	score_guide = {1:5, 2:5, 3:4}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags, "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00038, "Fray 2", allies, enemies, 3, null, extras)

	
func griffon():
	var pieces = load_level("griffon.level")
	var score_guide = {1:5, 2:5, 3:4, 4:3}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var traps = pieces[2]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags, "score_guide":score_guide, "traps":traps}
	return LevelTypes.Timed.new(00033, "Griffon", allies, enemies, 4, null, extras)
	
#might be too hard
func defuse_the_bomb():
	var pieces = load_level("defuse_the_bomb.level")
	var score_guide = {1:5, 2:5, 3:4}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags, "score_guide":score_guide}
	return LevelTypes.Timed.new(00034, "Defuse the Bomb", allies, enemies, 3, null, extras)
	
func ghost_boss(hard=false):
	var pieces
	var score_guide
	if hard:
		pieces = load_level("ghost_boss_hard.level")
		score_guide = {1:5, 2:5, 3:5, 4:4, 5:3} #not tested
	else:
		pieces = load_level("ghost_boss.level")
		score_guide = {1:5, 2:5, 3:5, 4:4, 5:3}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00035, "Ghostbusters MAX", allies, enemies, 5, null, extras)