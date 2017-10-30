extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_set():
	return LevelSet.new(1, "First", 
	[tutorial1(), tutorial2(), tutorial3(), first_steps(), second_steps()], [])
	
	
func tutorial1():
	var allies = {2: Cavalier, 4:Berserker} 
	var raw_enemies = load_level("tutorial1.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire", "hide_indirect_highlighting"]
	var tutorial = load("res://Tutorials/tutorial1.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial":tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new(00001, "Dynamic Duo", allies, enemies, 7, null, extras)


func tutorial2():
	var allies = {2: Berserker, 4: Cavalier}
	var raw_enemies = load_level("tutorial2.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire", "hide_indirect_highlighting"]
	var tutorial = load("res://Tutorials/tutorial2.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new(00002, "Death and Axes", allies, enemies, 7, null, extras)


func tutorial3():
	var allies = {2: Cavalier, 4:Berserker}
	var raw_enemies = load_level("tutorial3.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial = load("res://Tutorials/tutorial3.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new(00003, "The Indirect Blade is the Deadliest", allies, enemies, 7, null, extras)


func first_steps():
	var allies = {2: Berserker, 4: Cavalier}
	var raw_enemies = load_level("first_steps.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial = load("res://Tutorials/first_steps.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new(00004, "Baby's First Fight Against the Forces of Evil", allies, enemies, 5, null, extras)

func second_steps():
	var allies = {2: Berserker, 4: Cavalier}
	var raw_enemies = load_level("second_steps.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_waves", "no_inspire"]
	var tutorial = load("res://Tutorials/second_steps.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new(00005, "Tick Tock", allies, enemies, 2, null, extras)
