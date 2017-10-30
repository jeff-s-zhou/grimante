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
	[inspire(), shield_inspire(), corrosion(), griffon(), defuse_the_bomb(), ghost_boss()], 
	[shield_inspire(true), corrosion(true)])

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
	if hard:
		pieces = load_level("shield_inspire_hard.level")
	else:
		piece = load_level("shield_inspire.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/inspire.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new(00031, "Power of Friendship 2", allies, enemies, 3, null, extras)


func corrosion(hard=false):
	var pieces
	if hard:
		pieces = load_level("corrosion_hard.level")
	else:
		pieces = load_level("corrosion.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new(00032, "Corrosion", allies, enemies, 5, null, extras)

	
func griffon():
	var pieces = load_level("griffon.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new(00033, "Griffon", allies, enemies, 4, null, extras)
	

func defuse_the_bomb():
	var pieces = load_level("defuse_the_bomb.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new(00034, "Defuse the Bomb", allies, enemies, 3, null, extras)
	
func ghost_boss():
	var pieces = load_level("ghost_boss.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":true, "flags":[]}
	return LevelTypes.Timed.new(00035, "Ghostbusters MAX", allies, enemies, 6, null, extras)