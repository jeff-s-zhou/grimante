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
	[stormdancer_trials(), stormdancer_practice(), nemesis(), nemesis_big_fight(), trickshot(), double_boss(),
	mirror_world()], [stormdancer_practice(true)])

func stormdancer_trials():
	var tutorial = load("res://Tutorials/stormdancer_trial.gd").new()
	var flags = ["hints", "no_stars"]
	var challenges = []
	var base_id = 10018
	for i in range(1, 5):
		var trial_hint = funcref(tutorial, "get_trial" + str(i) + "_hints")
		var extras = {"free_deploy":false, "tutorial":trial_hint, "flags":flags}
		var pieces = load_level("stormdancer_trial" + str(i) +".level")
		var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
		var heroes = pieces[1]
		var challenge = LevelTypes.Timed.new(base_id + i, "Stormdancer Trial " + str(i), heroes, enemies, 1, null, extras) 
		challenges.append(challenge)

	return LevelTypes.Trial.new(10022, "Stormdancer Trials", challenges)
	
func stormdancer_practice(hard=false):
	var pieces = load_level("stormdancer_practice.level")
	var score_guide = {1:5, 2:5, 3:4, 4:3} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00037, "Stormdancer Drive", allies, enemies, 4, null, extras)


func nemesis():
	var pieces = load_level("nemesis.level")
	var score_guide = {1:5, 2:5, 3:4, 4:3} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00043, "Nemesis", allies, enemies, 4, null, extras)
	

func nemesis_big_fight():
	var pieces = load_level("nemesis_big_fight.level")
	var score_guide = {1:5, 2:5, 3:4, 4:3, 5:2} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00039, "Nemesis 2", allies, enemies, 5, null, extras)


func trickshot():
	var pieces = load_level("trickshot.level")
	var score_guide = {1:5, 2:5, 3:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00040, "Trick Shot", allies, enemies, 3, null, extras)
	
	
func double_boss():
	var pieces = load_level("double_boss.level")
	var score_guide = {1:5, 2:5, 3:4, 4:3} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00041, "McDouble", allies, enemies, 4, null, extras)
	
	
func mirror_world():
	var pieces = load_level("mirror_world.level")
	var score_guide = {1:5, 2:5, 3:5, 4:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":true, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00044, "Mirror World", allies, enemies, 4, null, extras)
	