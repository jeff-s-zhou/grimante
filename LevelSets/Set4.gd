extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
	
func get_set():
	return Set.new(4, "Fourth",
	[frost_knight(), frost_knight_drive(), wyvern(), wyvern2(), shield(), big_fight()], 
	[frost_knight_drive(true), wyvern(true), big_fight(true)])

func frost_knight():
	var tutorial = load("res://Tutorials/frost_knight_trial.gd").new()
	var trial1_hints = funcref(tutorial, "get_trial1_hints")
	var trial2_hints = funcref(tutorial, "get_trial2_hints")
	var trial3_hints = funcref(tutorial, "get_trial3_hints")
	var trial4_hints = funcref(tutorial, "get_trial4_hints")
	var trial5_hints = funcref(tutorial, "get_trial5_hints")
	
	var flags = ["no_stars", "no_inspire", "hints"]
	var extras1 = {"free_deploy":false, "tutorial":trial1_hints, "flags":flags}
	var extras2 = {"free_deploy":false, "tutorial":trial2_hints, "flags":flags}
	var extras3 = {"free_deploy":false, "tutorial":trial3_hints, "flags":flags}
	var extras4 = {"free_deploy":false, "tutorial":trial4_hints, "flags":flags}
	var extras5 = {"free_deploy":false, "tutorial":trial5_hints, "flags":flags}
	var extras6 = {"free_deploy":false, "flags":flags}
	
	var allies1 = {Vector2(3, 6): Archer, 3: FrostKnight}
	var allies2 = {Vector2(1, 3): FrostKnight}
	var allies3 = {Vector2(1, 4): FrostKnight, 4: Cavalier}
	var allies4 = {Vector2(4, 4): FrostKnight, 2: Berserker}
	var allies5 = {1: Assassin, 3: FrostKnight}
	var allies6 = {Vector2(3, 4): FrostKnight, 1: Cavalier, 5: Archer}

	var enemies1 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("frost_knight_trial1.level"))
	var enemies2 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("frost_knight_trial2.level"))
	var enemies3 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("frost_knight_trial3.level"))
	var enemies4 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("frost_knight_trial4.level"))
	var enemies5 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("frost_knight_trial5.level"))
	var enemies6 = EnemyWrappers.FiniteCuratedWrapper.new(load_level("frost_knight_trial6.level"))
	
	var challenge1 = LevelTypes.Timed.new(10008, "", allies1, enemies1, 1, null, extras1) 
	var challenge2 = LevelTypes.Timed.new(10009, "", allies2, enemies2, 1, null, extras2) 
	var challenge3 = LevelTypes.Timed.new(10010, "", allies3, enemies3, 1, null, extras3)
	var challenge4 = LevelTypes.Timed.new(10011, "", allies4, enemies4, 1, null, extras4)
	var challenge5 = LevelTypes.Timed.new(10012, "", allies5, enemies5, 1, null, extras5)
	var challenge6 = LevelTypes.Timed.new(10013, "", allies6, enemies6, 1, null, extras6)
	return LevelTypes.Trial.new(10013, "Frost Knight Trials", [challenge1, challenge2, challenge3, challenge4, challenge5, challenge6])
	

func frost_knight_drive(hard=false):
	var pieces
	if hard:
		pieces = load_level("frost_knight_drive_hard.level")
	else:
		pieces = load_level("frost_knight_drive.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var score_guide = {1:5, 2:5, 3:4, 4:4, 5:3} 
	var extras = {"flags":flags, "free_deploy":false, "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00017, "Frost Knight Drive", allies, enemies, 5, null, extras)


func wyvern(hard=false):
	var pieces
	var score_guide
	if hard:
		pieces = load_level("wyvern_hard.level")
		score_guide = {1:5, 2:5, 3:4, 4:4, 5:3} 
	else:
		pieces = load_level("wyvern.level")
		score_guide = {1:5, 2:5, 3:4, 4:4, 5:3} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false, "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00018, "Not Dragons", allies, enemies, 5, null, extras)
	
	
func wyvern2():
	var score_guide = {1:5, 2:5, 3:4} 
	var pieces = load_level("wyvern2.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false, "score_guide":score_guide}
	return LevelTypes.Timed.new(00019, "Rooks", allies, enemies, 3, null, extras)
	
#needs a harder level probably
func shield():
	var pieces = load_level("shield.level")
	var score_guide = {1:5, 2:5, 3:5, 4:4, 5:3, 6:2} #clearable on 2
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false, "score_guide":score_guide}
	return LevelTypes.Timed.new(00020, "Knockoff Shields", allies, enemies, 6, null, extras)
	
#needs an easier version
#this is really hard lol
func big_fight(hard=false):
	var pieces
	var score_guide
	if hard:
		pieces = load_level("big_fight_hard.level")
		score_guide = {1:5, 2:5, 3:5, 4:5, 5:4, 6:3} #this hasn't been tested
	else:
		pieces = load_level("big_fight.level")
		score_guide = {1:5, 2:5, 3:5, 4:4, 5:4, 6:3}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var tutorial = load("res://Tutorials/big_fight.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"flags":flags, "tutorial":tutorial_func, "hard":hard, "score_guide":score_guide}
	return LevelTypes.Timed.new(00021, "Big Fight", allies, enemies, 6, null, extras)