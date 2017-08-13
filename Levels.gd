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

var enemy_roster = load("res://constants.gd").new().enemy_roster
#
var enemy_modifiers = load("res://constants.gd").new().enemy_modifiers
var shield = enemy_modifiers["Shield"]
var poisonous = enemy_modifiers["Poisonous"]
var cloaked = enemy_modifiers["Cloaked"]
var rabid = enemy_modifiers["Predator"]
var corrosive = enemy_modifiers["Corrosive"]

#var available_unit_roster = get_node("/root/global").available_unit_roster

func load_level(file_name):
	var enemy_waves = {}
	for i in range(0, 9): #TODO: don't hardcode this in, so you can have varied game lengths
		#initialize a subdict for each wave
		enemy_waves[i] = {}

	var save = File.new()
	if !save.file_exists("res://Levels/" + file_name):
		return #Error!  We don't have a save to load

	# Load the file line by line and process that dictionary to restore the object it represents
	var current_line = {} # dict.parse_json() requires a declared dict.
	save.open("res://Levels/" + file_name, File.READ)
	while (!save.eof_reached()):
		current_line.parse_json(save.get_line())
		# First we need to create the object and add it to the tree and set its position.
		var name = current_line["name"]
		var coords = Vector2(int(current_line["pos_x"]), int(current_line["pos_y"]))
		var hp = int(current_line["hp"])
		var modifiers = current_line["modifiers"]
		var turn = int(current_line["turn"])
		
		var prototype = self.enemy_roster[name]
		
		var enemy_wave = enemy_waves[turn]
		enemy_wave[coords] = make(prototype, hp, modifiers)
	save.close()
	
	return enemy_waves

func make(prototype, hp, modifiers=null):
	return {"prototype": prototype, "hp": hp, "modifiers":modifiers}
	
var list = [tutorial1(), tutorial2(), tutorial3(), first_steps(), second_steps(), archer(), 
rule_of_three(), tutorial4(), tick_tock(), flying_solo(), star_power(), assassin(),
deploy(), speed_run(), sludge_lord(), grower(), grower2(), frost_knight(), swamp()]

#var list = [berserker_part1(), berserker_part2(), cavalier(), dead_or_alive(), reinforcements(),
#archer(), offsides(), tick_tock(), flying_solo(), assassin(), deploy(), mutation(),
#rising_tides(), inspire(), swamp(), stormdancer(), double_time(), defuse_the_bomb(),
#spoopy_ghosts(), pyromancer(), minesweeper(), star_power(), corsair(), frost_knight(),
#howl(), howl2(), saint(), corrosion(), shifting_sands(), shifting_sands2()]

func get_levels():
	for i in range(0, list.size() - 1):
		#change this call to set_next_level
		list[i].set_next_level(list[i+1])
	return list

func sandbox_enemies():
	var enemies = {0:{Vector2(3, 5): make(Grunt, 3)}}
	return EnemyWrappers.FiniteCuratedWrapper.new(enemies)
	
func sandbox_enemies2():
	var enemies = load_level("first_steps.level")
	return EnemyWrappers.FiniteCuratedWrapper.new(enemies)
	
func sandbox():  
	
	var flags = ["no_inspire"]
	var extras1 = {"free_deploy":false, "flags":flags}
	
	var allies1 = {2: Cavalier, 3: Archer, 4: Berserker}

	return LevelTypes.Timed.new("", allies1, sandbox_enemies(), 4, null, extras1) 


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


func deploy():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("deploy.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/deploy.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags, "tutorial":tutorial_func}
	return LevelTypes.Timed.new("Deploy", allies, enemies, 5, null, extras)


func speed_run():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("speed_run.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("Speed Run", allies, enemies, 2, null, extras)


func sludge_lord():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("sludge_lord.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("Jake Paul and Crew", allies, enemies, 3, null, extras)
	
	
func grower():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("grower.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("", allies, enemies, 3, null, extras)
	
	
func grower2():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("grower2.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("", allies, enemies, 5, null, extras)
	
	
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


func spoopy_ghosts():
	var allies = {1: Stormdancer, 2: Cavalier, 3:Berserker, 4:Assassin, 5: Archer}
	var raw_enemies = load_level("spoopy_ghosts.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	return LevelTypes.Timed.new("Spoopy Ghosts", allies, enemies, 7, null)


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



func corsair():
	var allies = {3: Corsair}
	var raw_enemies = load_level("corsair.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/corsair.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_stars"]
	var reinforcements = {4: {Vector2(3, 5): Berserker, Vector2(2, 6): Archer}}
	var extras = {"free_deploy":false, "reinforcements":reinforcements, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Corsair", allies, enemies, 4, null, extras)


func howl():
	var allies = {1: Archer, 2: Corsair, 4: Berserker, 5: FrostKnight}
	var raw_enemies = load_level("howl.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	return LevelTypes.Timed.new("Howl", allies, enemies, 6, null)


#func howl2():
#	var allies = {1: Assassin, 2: Archer, 4: Corsair, 5: FrostKnight}
#	var raw_enemies = load_level("howl2.level")
#	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
#	return LevelTypes.Timed.new("Howl 2", allies, enemies, 6, null)


func saint():
	var allies = {Vector2(2, 4): Cavalier, Vector2(3, 4): Saint}
	var raw_enemies = load_level("saint.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/saint.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var reinforcements = {4: {2: Berserker, 1: Archer, 3: Assassin}}
	var flags = ["no_stars"]
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags, "reinforcements":reinforcements}
	return LevelTypes.Timed.new("Saint", allies, enemies, 4, null, extras)


func corrosion():
	var allies = {1: Berserker, 2: Archer, 4: Cavalier, 5: Saint}
	var raw_enemies = load_level("corrosion.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	return LevelTypes.Timed.new("Corrosion", allies, enemies, 7, null)


func shifting_sands():
	var allies = {3: Berserker}
	var raw_enemies = load_level("shifting_sands.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/shifting_sands.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"tutorial": tutorial_func, "free_deploy": false, "shifting_sands":{Vector2(3, 5): 4}}
	return LevelTypes.Timed.new("Shifting Sands", allies, enemies, 7, null, extras)

func shifting_sands2():
	var allies = {1: FrostKnight, 2: Corsair, 4: Cavalier, 5: Saint}
	var raw_enemies = load_level("shifting_sands2.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"shifting_sands":{Vector2(3, 5): 1, Vector2(5, 5): 3}}#, Vector2(1, 3): 4}}
	return LevelTypes.Timed.new("We're In Deep Shift!", allies, enemies, 7, null, extras)
