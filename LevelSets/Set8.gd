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
	[saint_trials(), saint_practice(), assault(), god_is_faceless(), top_of_the_morning(), seraph_hell(), saints_row()], [])

func saint_trials():
	var tutorial = load("res://Tutorials/saint_trial.gd").new()
	var flags = ["no_stars"]
	var challenges = []
	var base_id = 10030
	for i in range(1, 5): #31, 32, 33, 34
		var trial_hint = funcref(tutorial, "get_trial" + str(i) + "_hints")
		var extras = {"free_deploy":false, "tutorial":trial_hint, "flags":flags}
		var pieces = load_level("saint_trial" + str(i) +".level")
		var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
		var heroes = pieces[1]
		var challenge = LevelTypes.Timed.new(base_id + i, "Saint Trial " + (str(i)), heroes, enemies, 1, null, extras) 
		challenges.append(challenge)
	return LevelTypes.Trial.new(10034, "Saint Trials", challenges)
	
func saint_practice():
	var pieces
	var score_guide
	pieces = load_level("saint_drive2.level")
	score_guide = {1:5, 2:5, 3:5, 4:4} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00046, "Saint Drive", allies, enemies, 4, null, extras)
	
	
func assault():
	var pieces
	var score_guide
	pieces = load_level("assault.level")
	score_guide = {1:5, 2:5, 3:5, 4:4, 5:4, 6:3} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":true, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00047, "Siegebreak", allies, enemies, 6, null, extras)
	

func god_is_faceless():
	var pieces
	var score_guide
	pieces = load_level("god_is_faceless.level")
	score_guide = {1:5, 2:5, 3:4, 4:4} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00048, "God is Faceless", allies, enemies, 4, null, extras)
	
	
func top_of_the_morning():
	var pieces
	var score_guide
	pieces = load_level("top_of_the_morning.level")
	score_guide = {1:5, 2:5, 3:4, 4:4} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00049, "Top O' The Morn", allies, enemies, 4, null, extras)
	
	
func seraph_hell():
	var pieces
	var score_guide
	pieces = load_level("seraph_hell.level")
	score_guide = {1:5, 2:5, 3:4, 4:3} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00050, "Spiral", allies, enemies, 4, null, extras)
	
	
func saints_row():
	var pieces
	var score_guide
	pieces = load_level("saints_row.level")
	score_guide = {1:5, 2:5, 3:5, 4:4, 5:3} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":true, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00051, "March", allies, enemies, 5, null, extras)