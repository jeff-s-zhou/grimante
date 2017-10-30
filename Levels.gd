extends Node

var set = load("res://LevelSets/Set1.gd").new().get_set()

var set2 = load("res://LevelSets/Set2.gd").new().get_set()

var set3 = load("res://LevelSets/Set3.gd").new().get_set()

var set4 = load("res://LevelSets/Set4.gd").new().get_set()

var set5 = load("res://LevelSets/Set5.gd").new().get_set()

var set6 = load("res://LevelSets/Set6.gd").new().get_set()

var set7 = load("res://LevelSets/Set7.gd").new().get_set()

var level_sets = [set, set2, set3, set4, set5, set6, set7]

func get_level_sets():
	return level_sets
	
#func sandbox(): 
#	var flags = []
#	#var score_guide = {0: SCORE.S_plus, 1:SCORE.S, 2: SCORE.A, 3: SCORE.B, 4: SCORE.C}
#	var extras1 = {"free_deploy":false, "flags":flags}
#	var raw_enemies = {0:{Vector2(2, 5): make(Grunt, 2)}}
#	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
#	var heroes = {0: Cavalier, 2: Berserker, 4:Assassin, 5: FrostKnight} 
#	return LevelTypes.Timed.new(33333, "", heroes, enemies, 2, null, extras1) 
#	
#func background():
#	var pieces = load_level("background.level")
#	var raw_enemies = pieces[0]
#	var allies = pieces[1]
#	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
#	var flags = []
#	var extras = {"flags":flags, "free_deploy":false}
#	return LevelTypes.Timed.new("Big Boss Fight", allies, enemies, 5, null, extras)

	
