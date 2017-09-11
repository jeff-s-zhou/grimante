extends Node

var EnemyWrappers = load("res://EnemyWrappers.gd").new()
var LevelTypes = load("res://LevelTypes.gd").new()

const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Fortifier = preload("res://EnemyPieces/FortifierPiece.tscn")
const Grower = preload("res://EnemyPieces/GrowerPiece.tscn")
const Drummer = preload("res://EnemyPieces/DrummerPiece.tscn")
const Melee = preload("res://EnemyPieces/MeleePiece.tscn")
const Ranged = preload("res://EnemyPieces/RangedPiece.tscn")
const Slime = preload("res://EnemyPieces/SlimePiece.tscn")
const Spectre = preload("res://EnemyPieces/SpectrePiece.tscn")
const Flanker = preload("res://EnemyPieces/FlankerPiece.tscn")
const BossGrunt = preload("res://EnemyPieces/BossGruntPiece.tscn")

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")
const Cavalier = preload("res://PlayerPieces/CavalierPiece.tscn")
const Archer = preload("res://PlayerPieces/ArcherPiece.tscn")
const Assassin = preload("res://PlayerPieces/AssassinPiece.tscn")
const Stormdancer = preload("res://PlayerPieces/StormdancerPiece.tscn")
const Pyromancer = preload("res://PlayerPieces/PyromancerPiece.tscn")
const FrostKnight = preload("res://PlayerPieces/FrostKnightPiece.tscn")
const Saint = preload("res://PlayerPieces/SaintPiece.tscn")
const Corsair = preload("res://PlayerPieces/CorsairPiece.tscn")

const Crusader = preload("res://PlayerPieces/CrusaderPiece.tscn")

var constants = load("res://constants.gd").new()
var enemy_roster = constants.enemy_roster

var hero_roster =constants.hero_roster
#
var enemy_modifiers = constants.enemy_modifiers
var shield = enemy_modifiers["Shield"]
var poisonous = enemy_modifiers["Poisonous"]
var cloaked = enemy_modifiers["Cloaked"]
var rabid = enemy_modifiers["Predator"]
var corrosive = enemy_modifiers["Corrosive"]

#var available_unit_roster = get_node("/root/global").available_unit_roster

func load_level(file_name):
	var enemy_waves = {}
	var heroes = {}
	for i in range(0, 9): #TODO: don't hardcode this in, so you can have varied game lengths
		#initialize a subdict for each wave
		enemy_waves[i] = {}

	var save = File.new()
	if !save.file_exists("res://Levels/" + file_name):
		return #Error!  We don't have a save to load

	# Load the file line by line and process that dictionary to restore the object it represents
	save.open("res://Levels/" + file_name, File.READ)
	while (!save.eof_reached()):
		var current_line = {} # dict.parse_json() requires a declared dict.
		current_line.parse_json(save.get_line())
		if current_line.has("hp"): #is an enemy
		# First we need to create the object and add it to the tree and set its position.
			var name = current_line["name"]
			var coords = Vector2(int(current_line["pos_x"]), int(current_line["pos_y"]))
			var hp = int(current_line["hp"])
			var modifiers = current_line["modifiers"]
			var turn = int(current_line["turn"])
			
			var prototype = self.enemy_roster[name]
			
			var enemy_wave = enemy_waves[turn]
			enemy_wave[coords] = make(prototype, hp, modifiers)
		else:
			var name = current_line["name"]
			var coords = Vector2(int(current_line["pos_x"]), int(current_line["pos_y"]))
			var prototype = self.hero_roster[name]
			heroes[coords] = prototype
	save.close()
	
	if heroes.empty():
		return enemy_waves # backwards compatibility with the old levels format
	else:
		return [enemy_waves, heroes]

func make(prototype, hp, modifiers=null):
	return {"prototype": prototype, "hp": hp, "modifiers":modifiers}
	
class LevelSet:
	var name = ""
	var levels = []
	var completed = false
	
	func _init(name, levels):
		self.name = name
		self.levels = levels
		
	func get_levels():
		for i in range(0, self.levels.size() - 1):
			#change this call to set_next_level
			self.levels[i].set_next_level(self.levels[i+1])
		return self.levels
		
	func complete():
		self.completed = true
		
var set = LevelSet.new("First", 
[tutorial1(), tutorial2(), tutorial3(), first_steps(), second_steps()])

var set2 = LevelSet.new("Second", 
[archer(), rule_of_three(), tutorial4(), tick_tock(), flying_solo()])

var set3 = LevelSet.new("Third",
[assassin(), sludge(), star_power(), seraph(), sludge_lord()])

var set4 = LevelSet.new("Fourth",
[frost_knight(), frost_knight_drive(), wyvern(), wyvern2(), shield(), big_fight()])

var set5 = LevelSet.new("Fifth",
[corsair_trials(), corsair_drive()])

var level_sets = [set, set2, set3, set4, set5]

#free levels that I think are still good

#defuse_the_domb(), double_time(), spoopy_ghosts(), minesweeper()

func get_level_sets():
	return level_sets
	
func sandbox(): 
	var flags = ["no_inspire", "bonus_star"]
	var extras1 = {"free_deploy":false, "flags":flags}
	var raw_enemies = {0:{Vector2(2, 5): make(BossGrunt, 1), Vector2(3, 3): make(Grunt, 4)}}
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var heroes = {2: Archer, 1: Assassin} 
#
	return LevelTypes.Timed.new("", heroes, enemies, 1, null, extras1) 

func tutorial1():
	var allies = {2: Cavalier, 4:Berserker} 
	var raw_enemies = load_level("tutorial1.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire", "hide_indirect_highlighting"]
	var tutorial = load("res://Tutorials/tutorial1.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial":tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Dynamic Duo", allies, enemies, 7, null, extras)


func tutorial2():
	var allies = {2: Berserker, 4: Cavalier}
	var raw_enemies = load_level("tutorial2.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire", "hide_indirect_highlighting"]
	var tutorial = load("res://Tutorials/tutorial2.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Death and Axes", allies, enemies, 7, null, extras)


func tutorial3():
	var allies = {2: Cavalier, 4:Berserker}
	var raw_enemies = load_level("tutorial3.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial = load("res://Tutorials/tutorial3.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("The Indirect Blade is the Deadliest", allies, enemies, 7, null, extras)


func first_steps():
	var allies = {2: Berserker, 4: Cavalier}
	var raw_enemies = load_level("first_steps.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial = load("res://Tutorials/first_steps.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Baby's First Fight Against the Forces of Evil", allies, enemies, 5, null, extras)

func second_steps():
	var allies = {2: Berserker, 4: Cavalier}
	var raw_enemies = load_level("second_steps.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_waves", "no_inspire"]
	var tutorial = load("res://Tutorials/second_steps.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Tick Tock", allies, enemies, 2, null, extras)


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
	
	var challenge1 = LevelTypes.Timed.new("", allies1, enemies1, 2, null, extras1) 
	var challenge2 = LevelTypes.Timed.new("", allies1, enemies2, 1, null, extras2)
	var challenge3 = LevelTypes.Timed.new("", allies1, enemies3, 1, null, extras3)
	var challenge4 = LevelTypes.Timed.new("", allies3, enemies4, 1, null, extras4)
	return LevelTypes.Trial.new("Archer Trials", [challenge1, challenge2, challenge3, challenge4])


func rule_of_three():
	var allies = {2: Berserker, 3:Archer, 4:Cavalier}
	var raw_enemies = load_level("rule_of_three.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire", "no_waves"]
	var tutorial = load("res://Tutorials/rule_of_three.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func}
	
	return LevelTypes.Timed.new("Love Triangle Hexagons", allies, enemies, 5, null, extras)
	
func tutorial4():
	var allies = {2: Cavalier, 4:Archer}
	var raw_enemies = load_level("tutorial4.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var tutorial = load("res://Tutorials/tutorial4.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var reinforcements = {3: { Vector2(2, 6): Berserker}}
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func, "reinforcements":reinforcements}
	
	return LevelTypes.Timed.new("Negative Reinforcement", allies, enemies, 6, null, extras)

	
func tick_tock():
	var allies = {2:Cavalier, 3:Berserker, 4: Archer}
	var raw_enemies = load_level("tick_tock.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var tutorial = load("res://Tutorials/tick_tock.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	#var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new("", allies, enemies, 5, null, extras)


func flying_solo():
	var allies = {2:Cavalier, 3:Berserker, 4: Archer}
	var raw_enemies = load_level("flying_solo.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new("Flying Solo", allies, enemies, 5, null, extras)
	

func star_power():
	var allies = {2: Cavalier, 4: Berserker}
	var raw_enemies = load_level("star_power.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/star_power.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire", "bonus_star"]
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Star Power", allies, enemies, 1, null, extras)


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
	
	var challenge1 = LevelTypes.Timed.new("", allies1, enemies1, 3, null, extras1) 
	var challenge2 = LevelTypes.Timed.new("", allies2, enemies2, 1, null, extras2)
	var challenge3 = LevelTypes.Timed.new("", allies2, enemies3, 1, null, extras3)
	return LevelTypes.Trial.new("Assassin Trials", [challenge1, challenge2, challenge3])


func sludge():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("sludge.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth", "no_stars"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("A Sticky Situation", allies, enemies, 5, null, extras)


func seraph():
	var allies = {1: Assassin, 2:Cavalier, 4:Berserker, 5: Archer}
	var raw_enemies = load_level("seraph.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Seraph", allies, enemies, 6, null, extras)


func sludge_lord():
	var allies = {2:Archer, 3: Cavalier, Vector2(3, 6): Berserker, 4: Assassin}
	var raw_enemies = load_level("sludge_lord.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Jake Paul and Crew", allies, enemies, 3, null, extras)


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
	
	var challenge1 = LevelTypes.Timed.new("", allies1, enemies1, 1, null, extras1) 
	var challenge2 = LevelTypes.Timed.new("", allies2, enemies2, 1, null, extras2) 
	var challenge3 = LevelTypes.Timed.new("", allies3, enemies3, 1, null, extras3)
	var challenge4 = LevelTypes.Timed.new("", allies4, enemies4, 1, null, extras4)
	var challenge5 = LevelTypes.Timed.new("", allies5, enemies5, 1, null, extras5)
	var challenge6 = LevelTypes.Timed.new("", allies6, enemies6, 1, null, extras6)
	return LevelTypes.Trial.new("Frost Knight Trials", [challenge1, challenge2, challenge3, challenge4, challenge5, challenge6])
	

func frost_knight_drive():
	var pieces = load_level("frost_knight_drive.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Frost Knight Drive", allies, enemies, 5, null, extras)
	
func wyvern():
	var pieces = load_level("wyvern.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Wyverns", allies, enemies, 5, null, extras)
	
func wyvern2():
	var pieces = load_level("wyvern2.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Castles", allies, enemies, 3, null, extras)
	
	
func shield():
	var pieces = load_level("shield.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Shield", allies, enemies, 6, null, extras)
	
func big_fight():
	var pieces = load_level("big_fight.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var tutorial = load("res://Tutorials/big_fight.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"flags":flags, "tutorial":tutorial_func}
	return LevelTypes.Timed.new("Big Fight", allies, enemies, 7, null, extras)
	
func corsair_trials():
	var tutorial = load("res://Tutorials/corsair_trial.gd").new()
	var flags = ["no_stars", "no_inspire", "hints"]
	var challenges = []
	for i in range(6, 7):
		var trial_hint = funcref(tutorial, "get_trial" + str(i) + "_hints")
		var extras = {"free_deploy":false, "tutorial":trial_hint, "flags":flags}
		var pieces = load_level("corsair_trial" + str(i) +".level")
		var enemies = EnemyWrappers.FiniteCuratedWrapper.new(pieces[0])
		var heroes = pieces[1]
		var challenge = LevelTypes.Timed.new("", heroes, enemies, 1, null, extras) 
		challenges.append(challenge)
	return LevelTypes.Trial.new("Corsair Trials", challenges)
	
func football():
	var pieces = load_level("football.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Football", allies, enemies, 3, null, extras)
	
	
func corsair_drive():
	var pieces = load_level("corsair_drive.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Corsair Drive", allies, enemies, 4, null, extras)
	
func ghostbusters():
	var pieces = load_level("ghostbusters.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	return LevelTypes.Timed.new("Ghostbusters", allies, enemies, 3, null, extras)
	
func ghostbusters2():
	var pieces = load_level("ghostbusters2.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire"]
	var extras = {"flags":flags, "free_deploy":true}
	return LevelTypes.Timed.new("Ghostbusters 2", allies, enemies, 3, null, extras)
	
func boss_fight():
	var pieces = load_level("boss_fight.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags, "free_deploy":false}
	var tutorial = load("res://Tutorials/boss_fight.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	return LevelTypes.Timed.new("Boss Fight", allies, enemies, 3, null, extras)
	
func big_boss_fight():
	var pieces = load_level("big_boss_fight.level")
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire"]
	var extras = {"flags":flags, "free_deploy":true}
	return LevelTypes.Timed.new("Big Boss Fight", allies, enemies, 3, null, extras)

func swamp():
	var allies = {1:Archer, 2: FrostKnight, 3:Berserker, 4:Cavalier, 5: Assassin}
	var raw_enemies = load_level("swamp.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth", "no_inspire"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("Dagobah", allies, enemies, 6, null, extras)

	
func inspire():
	var allies = {1: Berserker, 5: Cavalier}
	var raw_enemies = load_level("inspire.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/inspire.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_fifth"]
	var reinforcements = {3: {2: Archer, 3: Assassin}}
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "reinforcements":reinforcements, "flags":flags}
	return LevelTypes.Timed.new("Power of Friendship", allies, enemies, 7, null, extras)
	
	
func stormdancer():
	var allies = {3: Stormdancer}
	var raw_enemies = load_level("stormdancer.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/stormdancer.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_stars"]
	var reinforcements = {3: {3: Cavalier}, 4: {Vector2(1, 2): Berserker}}
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "reinforcements":reinforcements, "flags":flags}
	return LevelTypes.Timed.new("Stormdancer", allies, enemies, 4, null, extras)


func double_time():
	var allies = {1: FrostKnight, 2: Cavalier, 3:Berserker, 4:Assassin, 5: Archer}
	var raw_enemies = load_level("double_time.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("Double Time", allies, enemies, 7, null, extras)
	

func defuse_the_bomb():
	var allies = {1: Stormdancer, 2: Cavalier, 3:Berserker, 4:Assassin, 5: Archer}
	var raw_enemies = load_level("defuse_the_bomb.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("Defuse the Bomb", allies, enemies, 3, null, extras)


func pyromancer():
	var allies = {3: Pyromancer}
	var raw_enemies = load_level("pyromancer.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/pyromancer.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_stars"]
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Pyromancer", allies, enemies, 4, null, extras)


func minesweeper():
	var allies = {1: Pyromancer, 2: Cavalier, 4: Stormdancer, 5: Assassin}
	var raw_enemies = load_level("minesweeper.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/minesweeper.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"tutorial": tutorial_func}
	return LevelTypes.Timed.new("Minesweeper", allies, enemies, 7, null, extras)


func howl():
	var allies = {1: Archer, 2: Corsair, 4: Berserker, 5: FrostKnight}
	var raw_enemies = load_level("howl.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	return LevelTypes.Timed.new("Howl", allies, enemies, 6, null)