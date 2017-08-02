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
	
	

#var list = [berserker_part1(), berserker_part2(), cavalier(), dead_or_alive(), reinforcements(),
#archer(), offsides(), tick_tock(), flying_solo(), assassin(), deploy(), mutation(),
#rising_tides(), inspire(), swamp(), stormdancer(), double_time(), defuse_the_bomb(),
#spoopy_ghosts(), pyromancer(), minesweeper(), star_power(), corsair(), frost_knight(),
#howl(), howl2(), saint(), corrosion(), shifting_sands(), shifting_sands2()]

var list = [tutorial1()]

func get_levels():
	for i in range(0, list.size() - 1):
		#change this call to set_next_level
		list[i].set_next_level(list[i+1])
	return list


func sandbox_allies():
	return {3: Archer}
	
func sandbox_enemies():
	var enemies = {0:{Vector2(3, 6): make(Spectre, 5)}}
	#var enemies = load_level("defuse_the_bomb.level")
	return EnemyWrappers.FiniteCuratedWrapper.new(enemies)
	
func sandbox_extras():
	#return {"shifting_sands_tiles": {Vector2(3, 6): 4}, "tutorial":tutorial}
	var tutorial = load("res://Tutorials/tutorial3.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	#return {"flags":flags, "tutorial":tutorial_func}
	#return {"flags":flags}
	return {}
	
func sandbox():  
	return LevelTypes.Timed.new("Test Name", sandbox_allies(), sandbox_enemies(), 3, null, sandbox_extras()) 

func sandbox2():
	var part1 = LevelTypes.Timed.new("Test Name", sandbox_allies(), sandbox_enemies(), 3, null, sandbox_extras()) 
	var part2 = LevelTypes.Sandbox.new("Test Name", sandbox_allies(), sandbox_enemies(), 3, null, sandbox_extras()) 
	var part3 = LevelTypes.Timed.new("Test Name 2", sandbox_allies2(), sandbox_enemies(), 3, null, sandbox_extras()) 
	return LevelTypes.MultiLevel.new([part1, part2, part3])

func tutorial1():
	var allies = {2: Cavalier, 4:Berserker} 
	var raw_enemies = load_level("tutorial1.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial = load("res://Tutorials/tutorial1.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial":tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Dynamic Duo", allies, enemies, 7, null, extras)


func tutorial2():
	var allies = {2: Berserker, 4: Cavalier}
	var raw_enemies = load_level("tutorial2.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
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
	
	return LevelTypes.Timed.new("Baby's First Fight Against the Forces of Evil", allies, enemies, 7, null, extras)


func archer():
	var allies = {3:Archer}
	var raw_enemies = load_level("archer.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var reinforcements = {5: { Vector2(5, 7): Berserker}}
	var flags = ["no_stars", "no_turns", "no_inspire", "no_waves"]
	var tutorial = load("res://Tutorials/archer.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "reinforcements":reinforcements, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Take a Bow", allies, enemies, 7, null, extras)


func rule_of_three():
	var allies = {2: Berserker, 3:Archer, 4:Cavalier}
	var raw_enemies = load_level("rule_of_three.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_turns", "no_inspire", "no_waves"]
	var tutorial = load("res://Tutorials/rule_of_three.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func}
	
	return LevelTypes.Timed.new("Love Triangle", allies, enemies, 7, null, extras)
	
func tutorial4():
	var allies = {2: Cavalier, 4:Archer}
	var raw_enemies = load_level("tutorial4.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_turns", "no_inspire"]
	var tutorial = load("res://Tutorials/tutorial4.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var reinforcements = {4: { Vector2(2, 6): Berserker}}
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func, "reinforcements":reinforcements}
	
	return LevelTypes.Timed.new("", allies, enemies, 7, null, extras)

	
func tick_tock():
	var allies = {2:Cavalier, 3:Berserker, 4: Archer}
	var raw_enemies = load_level("tick_tock.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var tutorial = load("res://Tutorials/tick_tock.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	#var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new("Tick Tock", allies, enemies, 7, null, extras)


func flying_solo():
	var allies = {2:Cavalier, 3:Berserker, 4: Archer}
	var raw_enemies = load_level("flying_solo.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var extras = {"free_deploy":false, "flags":flags}
	return LevelTypes.Timed.new("Flying Solo", allies, enemies, 7, null, extras)
	

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
	var allies = {3:Assassin}
	var raw_enemies = load_level("assassin.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/assassin.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire"]
	var reinforcements = {3: {3: Archer, 5:Cavalier}}
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func, "reinforcements":reinforcements}
	var lesson = LevelTypes.Timed.new("Assassin", allies, enemies, 7, null, extras)
	
	var allies = {1: Archer, 3:Assassin, 5: Berserker}
	var raw_enemies = load_level("assassin_sandbox.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/assassin_sandbox.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire"]
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func}
	var sandbox = LevelTypes.Sandbox.new("Assassin's Sandbox", allies, enemies, null, extras)
	
	var allies = {2: Cavalier, 3:Assassin, 4: Archer}
	var raw_enemies = load_level("assassin_trial.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/assassin_trial.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire"]
	var extras = {"free_deploy":false, "flags":flags, "tutorial":tutorial_func}
	var trial = LevelTypes.Timed.new("Assassin's Sandbox", allies, enemies, 1, null, extras)
	
	return LevelTypes.MultiLevel.new([lesson, sandbox, trial])


func deploy():
	var allies = {1: Cavalier, 2:Archer, 4:Assassin, 5: Berserker}
	var raw_enemies = load_level("deploy.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/deploy.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags, "tutorial":tutorial_func}
	return LevelTypes.Timed.new("Deploy", allies, enemies, 7, null, extras)

	
func mutation():
	var allies = {1: Cavalier, 2: Berserker, 4:Archer, 5:Assassin}
	var raw_enemies = load_level("mutation.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/mutation.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_inspire", "no_fifth"]
	var extras = {"flags":flags, "tutorial":tutorial_func}
	return LevelTypes.Timed.new("Mutation", allies, enemies, 7, null, extras)

	
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
	
	
func swamp():
	var allies = {2: Cavalier, 3:Archer, 4:Assassin, Vector2(3, 6): Berserker}
	var raw_enemies = load_level("swamp.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_fifth"]
	var extras = {"flags":flags}
	return LevelTypes.Timed.new("Dagobah", allies, enemies, 7, null, extras)

	
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
	var allies = {1: Stormdancer, 2: Cavalier, 3:Berserker, 4:Assassin, 5: Archer}
	var raw_enemies = load_level("double_time.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars"]
	var tutorial = load("res://Tutorials/double_time.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var extras = {"tutorial":tutorial_func, "flags":flags}
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

	
func frost_knight():
	var allies = {2: Archer, 3: FrostKnight}
	var raw_enemies = load_level("frost_knight.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial = load("res://Tutorials/frost_knight.gd").new()
	var tutorial_func = funcref(tutorial, "get")
	var flags = ["no_stars"]
	var extras = {"free_deploy":false, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Frost Knight", allies, enemies, 4, null, extras)


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
