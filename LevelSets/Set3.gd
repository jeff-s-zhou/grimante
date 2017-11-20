extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func get_set():
	return Set.new(3, "Third",
	[assassin(), sludge(), star_power(), seraph(), sludge_lord()], [])

func assassin():
	var tutorial = load("res://Tutorials/assassin_trial.gd").new()
	var trial1_hints = funcref(tutorial, "get_trial1_hints")
	var trial2_hints = funcref(tutorial, "get_trial2_hints")
	var trial3_hints = funcref(tutorial, "get_trial3_hints")
	
	var flags = ["no_stars", "no_inspire", "hints"]
	var extras1 = {"free_deploy":false, "tutorial":trial1_hints, "flags":flags}
	var extras2 = {"free_deploy":false, "tutorial":trial2_hints, "flags":flags}
	var extras3 = {"free_deploy":false, "tutorial":trial3_hints, "flags":flags}
	
	var allies1 = {3: Assassin}
	var allies2 = {2: Cavalier, 3: Assassin}

	var enemies1 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("assassin_trial1.level"))
	var enemies2 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("assassin_trial2.level"))
	var enemies3 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("assassin_trial3.level"))
	
	var challenge1 = LevelTypes.Timed.new(10005, "", allies1, enemies1, 3, null, extras1) 
	var challenge2 = LevelTypes.Timed.new(10006, "", allies2, enemies2, 1, null, extras2)
	var challenge3 = LevelTypes.Timed.new(10007, "", allies2, enemies3, 1, null, extras3)
	return LevelTypes.Trial.new(00012, "Assassin", [challenge1, challenge2, challenge3])


func sludge():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("sludge.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/sludge.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire", "no_fifth", "no_stars"]
	var score_guide = {1:5, 2:5, 3:4, 4:4, 5:3} 
	var extras = {"flags":flags, "free_deploy":false, "tutorial":tutorial_func, "score_guide":score_guide}
	return LevelTypes.Timed.new(00013, "A Sticky Situation", allies, enemies, 5, null, extras)
	

func star_power():
	var allies = {2: Cavalier, 4: Berserker}
	var raw_enemies = load_level("star_power.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/star_power.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire"]
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new(00011, "Star Power", allies, enemies, 1, null, extras)


func seraph():
	var allies = {1: Assassin, 2:Cavalier, 4:Berserker, 5: Archer}
	var raw_enemies = load_level("seraph.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/seraph.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire", "no_fifth"]
	var score_guide = {1:5, 2:5, 3:4, 4:4, 5:3} 
	var extras = {"flags":flags, "free_deploy":false, "score_guide":score_guide, "tutorial":tutorial_func}
	return LevelTypes.Timed.new(00014, "Death Wish", allies, enemies, 6, null, extras)


func sludge_lord():
	var allies = {2:Archer, 3: Cavalier, Vector2(3, 6): Berserker, 4: Assassin}
	var raw_enemies = load_level("sludge_lord.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var score_guide = {1:5, 2:5, 3:4} 
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new(00015, "Jake Paul and Crew", allies, enemies, 3, null, extras)