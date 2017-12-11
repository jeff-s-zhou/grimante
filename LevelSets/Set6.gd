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
	[inspire(), shield_inspire(), unstable(), griffon(), defuse_the_bomb(), ghost_boss()], 
	[shield_inspire(true)])

func inspire():
	var allies = {1: Berserker, 5: Cavalier}
	var raw_enemies = load_level("inspire.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/inspire.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_fifth"]
	var reinforcements = {3: {2: Archer, 3: Assassin}}
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "reinforcements":reinforcements, "flags":flags}
	return LevelTypes.Timed.new(00030, "Power of Friendship", allies, enemies, 4, null, extras)
	

func shield_inspire(hard=false):
	var pieces
	var score_guide
	if hard:
		pieces = load_level("shield_inspire_hard.level")
		score_guide = {1:5, 2:5, 3:4} #not tested
	else:
		pieces = load_level("shield_inspire.level")
		score_guide = {1:5, 2:5, 3:4} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/shield_inspire.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags, "tutorial": tutorial_func, "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00031, "Power of Friendship 2", allies, enemies, 3, null, extras)


func unstable(hard=false):
	var pieces
	var score_guide
	pieces = load_level("unstable.level")
	#score_guide = {1:5, 2:5, 3:5, 4:4, 5:3}
	score_guide = {1:5, 2:5, 3:4, 4:3}
	var raw_enemies = pieces[0]
	var allies = {1:Archer, 2: Assassin, 4:Corsair, 5:FrostKnight} #pieces[1]
	var traps = pieces[2]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var tutorial = load("res://Tutorials/unstable.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "flags":flags, "hard":hard, "score_guide":score_guide, "traps":traps, "tutorial":tutorial_func}
	return LevelTypes.Timed.new(00032, "Boom", allies, enemies, 4, null, extras)

	
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
		score_guide = {1:5, 2:5, 3:5, 4:4, 5:3, 6:2} #not tested
	else:
		pieces = load_level("ghost_boss.level")
		score_guide = {1:5, 2:5, 3:5, 4:4, 5:3, 6:2}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":true, "flags":[], "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00035, "Ghostbusters MAX", allies, enemies, 6, null, extras)