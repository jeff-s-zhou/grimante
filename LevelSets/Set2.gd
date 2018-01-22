extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func get_set():
	return Set.new(2, "Second", 
	[archer(), rule_of_three(), tutorial4(), tick_tock(), flying_solo()], [])

func archer():
	var tutorial = load("res://Tutorials/archer_trial.gd").new()
	var trial1_hints = funcref(tutorial, "get_trial1_hints")
	var trial2_hints = funcref(tutorial, "get_trial2_hints")
	var trial3_hints = funcref(tutorial, "get_trial3_hints")
	var trial4_hints = funcref(tutorial, "get_trial4_hints")
	
	var flags = ["no_stars", "no_waves", "no_inspire", "hints"]
	var extras1 = {"free_deploy":false, "tutorial":trial1_hints, "flags":flags}
	var extras2 = {"free_deploy":false, "tutorial":trial2_hints, "flags":flags}
	var extras3 = {"free_deploy":false, "tutorial":trial3_hints, "flags":flags}
	var extras4 = {"free_deploy":false, "tutorial":trial4_hints, "flags":flags}
	
	var allies1 = {3: Archer}
	var allies3 = {Vector2(3, 6): Cavalier, 3:Archer}

	var enemies1 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("archer_trial1.level"))
	var enemies2 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("archer_trial2.level"))
	var enemies3 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("archer_trial3.level"))
	var enemies4 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("archer_trial4.level"))
	
	
	var challenge1 = LevelTypes.Timed.new(10001, "Archer Trial 1", allies1, enemies1, 2, null, extras1) 
	var challenge2 = LevelTypes.Timed.new(10002, "Archer Trial 2", allies1, enemies2, 1, null, extras2)
	var challenge3 = LevelTypes.Timed.new(10003, "Archer Trial 3", allies1, enemies3, 1, null, extras3)
	var challenge4 = LevelTypes.Timed.new(10004, "Archer Trial 4", allies3, enemies4, 1, null, extras4)
	return LevelTypes.Trial.new(10004, "Archer Trials", [challenge1, challenge2, challenge3, challenge4])


func rule_of_three():
	var allies = {2: Berserker, 3:Archer, 4:Cavalier}
	var raw_enemies = load_level("rule_of_three.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire", "no_waves"]
	var tutorial = load("res://Tutorials/rule_of_three.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var score_guide = {1:5, 2:5, 3:4, 4:3} 
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func, "score_guide":score_guide}
	
	
	return LevelTypes.Timed.new(00007, "Love Triangle Hexagons", allies, enemies, 4, null, extras)
	
func tutorial4():
	var allies = {2: Cavalier, 4:Archer}
	var raw_enemies = load_level("tutorial4.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var tutorial = load("res://Tutorials/tutorial4.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var reinforcements = {3: { Vector2(2, 6): Berserker}}
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func, "reinforcements":reinforcements}
	
	return LevelTypes.Timed.new(00008, "Negative Reinforcement", allies, enemies, 6, null, extras)

	
func tick_tock():
	var allies = {2:Cavalier, 3:Berserker, 4: Archer}
	var raw_enemies = load_level("tick_tock.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var tutorial = load("res://Tutorials/tick_tock.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var score_guide = {1:5, 2:5, 3:5, 4:4, 5:3} 
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags, "score_guide":score_guide}
	return LevelTypes.Timed.new(00009, "Quarterbats", allies, enemies, 5, null, extras)


func flying_solo():
	var allies = {2:Cavalier, 3:Berserker, 4: Archer}
	var raw_enemies = load_level("flying_solo.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var score_guide = {1:5, 2:5, 3:5, 4:4, 5:3} 
	var extras = {"free_deploy":false, "flags":flags, "score_guide":score_guide}
	return LevelTypes.Timed.new(00010, "Flying Solo", allies, enemies, 5, null, extras)