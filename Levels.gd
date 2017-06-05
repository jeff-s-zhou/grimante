extends Node

var EnemyWrappers = load("res://EnemyWrappers.gd").new()
var LevelTypes = load("res://LevelTypes.gd").new()

var ForcedActionPrototype = load("res://UI/ForcedAction.tscn")
var RulePrototype = load("res://UI/TutorialRule.tscn")
var TutorialPrototype = load("res://UI/TutorialManager.tscn")

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

var enemy_roster = load("res://constants.gd").new().enemy_roster
#
var enemy_modifiers = load("res://constants.gd").new().enemy_modifiers
var shield = enemy_modifiers["Shield"]
var poisonous = enemy_modifiers["Poisonous"]
var cloaked = enemy_modifiers["Cloaked"]
var rabid = enemy_modifiers["Rabid"]
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
	

func add_player_start_rule(tutorial, turn, text_list, coords=null):
	var player_start_rule = RulePrototype.instance()
	player_start_rule.initialize(text_list)
	tutorial.add_player_turn_start_rule(player_start_rule, turn, coords)
	
func add_enemy_end_rule(tutorial, turn, text_list):
	var enemy_end_rule = RulePrototype.instance()
	enemy_end_rule.initialize(text_list)
	tutorial.add_enemy_turn_end_rule(enemy_end_rule, turn)

func add_forced_action(tutorial, turn, initial_coords, text, final_coords, text2, result=null):
	var forced_action = ForcedActionPrototype.instance()
	forced_action.initialize(initial_coords, text, final_coords, text2, result)
	tutorial.add_forced_action(forced_action, turn)


func sandbox_allies():
	return [Assassin, Berserker, Cavalier] #2: Cavalier, 3: Archer, 4: Assassin}

func sandbox_enemies():
	var turn_power_levels = [1300, 0, 500, 0, 600, 0, 650, 0, 700]
	return EnemyWrappers.FiniteGeneratedWrapper.new(turn_power_levels)
	
func sandbox_enemies2():
	var enemies = [{Vector2(3, 2): make(Spectre, 3), Vector2(3, 4): make(Slime, 4)}]
	#var enemies = load_level("level2.save")
	return EnemyWrappers.FiniteCuratedWrapper.new(enemies)\
	
func sandbox_extras():
	#return {"shifting_sands_tiles": {Vector2(3, 6): 4}, "tutorial":tutorial}
	return {"required_units":{2: Archer, 3: FrostKnight}}
	
func sandbox_extras2():
	return {"shadow_wall_tiles": [Vector2(3, 3), Vector2(3, 4)], "required_units":{1: Assassin, 2: Berserker, 4: Corsair, 5: Archer}}
	#return {"required_units":{1: Cavalier, 2: Berserker, 3: Pyromancer, 4: Corsair, 5: Archer}}

func sandbox_level():
	return LevelTypes.Timed.new("Test Name", sandbox_allies(), sandbox_enemies2(), 7, null, sandbox_extras()) 

var list = [sandbox_level()]

func berserker_part1_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["Clear the board of enemies to win."]
	add_player_start_rule(tutorial, 1, text)
	
	var text = ["When all of your pieces have moved, your turn ends."]
	var fa_text1 = "Click on the Berserker to select it."
	var fa_text2 = "Click on this tile to move the Berserker here."
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text2, text)
	
	text = ["Enemies move down one tile each turn.", \
	"If an enemy exits from the bottom of the board, you lose."]
	add_enemy_end_rule(tutorial, 1, text)

	text = ["The Berserker's Direct Attack deals 4 damage to an enemy's Power.", \
	"If an enemy's Power reaches 0, it is KOed."]
	fa_text1 = "Select the Berserker"
	fa_text2 = "Select the Enemy to attack it."
	add_forced_action(tutorial, 2, Vector2(3, 5), fa_text1, Vector2(3, 3), fa_text2, text)
	
	text = ["When the Berserker kills an enemy, it moves to its tile. "]
	fa_text1 = "Kill the Enemy"
	fa_text2 = ""
	add_forced_action(tutorial, 3, Vector2(3, 5), fa_text1, Vector2(3, 4), fa_text2, text)
	
	text = ["Clear the board of remaining enemies to win. "]
	add_player_start_rule(tutorial, 4, text)
	
	return tutorial

#BERSERKER PART 1
func berserker_part1():
	var allies = []
	var raw_enemies = load_level("berserker_part1.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial_func = funcref(self, "berserker_part1_tutorial")
	var extras = {"free_deploy":false, "required_units":{3: Berserker}, "tutorial":tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Berserker Part 1", allies, enemies, 7, null, extras)
	

func berserker_part2_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["You've learned how to use the Berserker's Direct Attack.", \
	"However, that's not all the Berserker can do."]
	add_player_start_rule(tutorial, 1, text)
	
	var text = ["When the Berserker moves to an empty tile, it uses its Indirect Attack, Ground Slam.", "Ground Slam deals 2 damage to adjacent enemies."]
	var fa_text1 = "Move the Berserker next to these enemies."
	var fa_text2 = ""
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text2, text)
	
	
	text = ["The Berserker's Indirect Attack stuns enemies.", \
	"The Stun Effect prevents enemies from moving their next turn."]
	fa_text1 = "Let’s attack these High Power enemies."
	fa_text2 = ""
	add_forced_action(tutorial, 2, Vector2(3, 5), fa_text1, Vector2(3, 3), fa_text2, text)


	text = ["Clear the board."]
	add_player_start_rule(tutorial, 3, text)
	
	return tutorial
	

#BERSERKER PART 2
func berserker_part2():
	var allies = []
	var raw_enemies = load_level("berserker_part2.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial_func = funcref(self, "berserker_part2_tutorial")
	var extras = {"free_deploy":false, "required_units":{3: Berserker}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Berserker Part 2", allies, enemies, 7, null, extras)


func cavalier_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["The Cavalier has arrived! Let's see what it can do."]
	add_player_start_rule(tutorial, 1, text)
	
	var fa_text1 = "The Cavalier can move any number of tiles in all six directions."
	var fa_text2 = ""
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(0, 4), fa_text2)
	
	
	text = ["The Cavalier can run through enemies with its Indirect Attack: Trample.", \
	"Trample deals 2 damage to each enemy."]
	fa_text1 = "Now let's clean up some enemies."
	fa_text2 = ""
	add_forced_action(tutorial, 2, Vector2(0, 4), fa_text1, Vector2(0, 0), fa_text2, text)
	
	text = ["The Cavalier can use its Direct Attack, Charge, on an enemy when there is nothing blocking its path.", \
	"Charge deals 1 damage for each tile travelled to the first enemy it hits, and the enemy behind it."]
	fa_text1 = "Now let's use the Cavalier's Direct Attack, Charge."
	fa_text2 = ""
	add_forced_action(tutorial, 3, Vector2(0, 0), fa_text1, Vector2(5, 5), fa_text2, text)


	text = ["Can you clear the board before the enemies reach the bottom?"]
	add_player_start_rule(tutorial, 3, text)
	
	return tutorial

#CAVALIER
func cavalier():
	var allies = []
	var raw_enemies = load_level("cavalier.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire"]
	var tutorial_func = funcref(self, "cavalier_tutorial")
	var extras = {"free_deploy":false, "required_units":{3: Cavalier}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Cavalier", allies, enemies, 7, null, extras)


func dead_or_alive_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var text = [" Here, both Heroes have already moved and are on cooldown.", 
	"Let's see what happens when the Enemies try to move forward.",
	"Press the End Turn button when you're ready."]
	add_player_start_rule(tutorial, 1, text)
	
	text = ["When an Enemy moves forward onto a tile occupied by a Hero, it shoves the Hero.", 
	"If the Enemy's Power >= Hero's Armor, the Hero is KOed.",
	"Otherwise the Hero is pushed back 1 tile.",
	"If the Hero is pushed off the map, it is KOed."]
	
	add_enemy_end_rule(tutorial, 1, text)
	
	text = ["The Berserker is KOed, but he's not out yet!"]
	
	add_player_start_rule(tutorial, 2, text)
	
	text = ["Heroes can be revived if the tile they were KOed on is empty, and another Hero moves adjacent to the tile.",
	"However, if all heroes are KOed, you lose."]
	
	var fa_text1 = "Let's move the Cavalier here."
	var fa_text2 = ""
	add_forced_action(tutorial, 2, Vector2(4, 7), fa_text1, Vector2(1, 4), fa_text2, text)
	
	text = ["Each Hero can move once per turn.", 
	"Right Click or press Escape to deselect a Hero."]
	add_player_start_rule(tutorial, 3, text)

	
	return tutorial


#DEAD OR ALIVE
func dead_or_alive():
	var allies = []
	var raw_enemies = load_level("dead_or_alive.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_waves", "no_inspire", "placed"]
	var tutorial_func = funcref(self, "dead_or_alive_tutorial")
	var extras = {"free_deploy":false, "required_units":{Vector2(4, 6): Cavalier, Vector2(2, 5): Berserker}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Dead or Alive", allies, enemies, 7, null, extras)
	

func reinforcements_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["These are Reinforcement Hexes.", 
	"An enemy unit will appear on a Reinforcement Hex on the following turn."]
	add_player_start_rule(tutorial, 1, text, Vector2(5, 4))
	
	text = ["If a Hero stands on a Reinforcement Hex, it is KOed.", 
	"If an Enemy stands on a Reinforcement Hex, it absorbs the Reinforcement and gains its Power."]
	add_enemy_end_rule(tutorial, 1, text)
	
	var text = ["Check the top left of the screen to see when the next Wave of Reinforcements is going to arrive."]
	add_player_start_rule(tutorial, 2, text)
	
	var text = ["If you forget what a Piece does, double click on it to bring up a summary."]
	add_player_start_rule(tutorial, 3, text)
	
	return tutorial
	
func reinforcements():
	var allies = []
	var raw_enemies = load_level("reinforcements.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	
	var flags = ["no_stars", "no_turns", "no_inspire"]
	var tutorial_func = funcref(self, "reinforcements_tutorial")
	var extras = {"free_deploy":false, "required_units":{4: Berserker, 2: Cavalier}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Reinforcements!", allies, enemies, 7, null, extras)


func archer_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["The Archer is here!"]
	add_player_start_rule(tutorial, 1, text)
	
	var fa_text1 = "The Archer can Direct Attack from a distance by firing a Piercing Arrow."
	text = ["The Piercing Arrow hits the first target along a line for 3 damage."]
	
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 4), fa_text1, text)
	
	fa_text1 = "The Archer's Piercing Arrow has a special effect when it kills an enemy."
	text = ["If the Archer's Piercing Arrow kills, it continues to travel.", 
	"The arrow deals 1 less damage to each successive enemy until it fails to kill, or its damage reaches 0."]
	
	add_forced_action(tutorial, 2, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text1, text)
	
	fa_text1 = "The Archer can shoot along \"hex diagonal\" angles to hit tricky targets."
	add_force_action(tutorial, 3, Vector2(3, 7), fa_text1, Vector2(1, 3), fa_text1)
	
	text = ["When the Archer moves, its passive causes it to automatically fire a Piercing Arrow directly north."]
	add_forced_action(tutorial, 4, Vector2(3, 7), "", Vector2(4, 7), "", text)
	
	
	text = ["The Archer's shots are blocked by other Heroes.", 
	"Can you clear the board this turn?"]
	add_player_start_rule(tutorial, 5, text)
	
	
	return tutorial


func archer():
	var allies = []
	var raw_enemies = load_level("archer.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var reinforcements = {3: { 5: Berserker}}
	var flags = ["no_stars", "no_turns", "no_inspire"]
	var tutorial_func = funcref(self, "archer_tutorial")
	var extras = {"free_deploy":false, "reinforcements":reinforcements, "required_units":{3:Archer}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Archer", allies, enemies, 7, null, extras)



#SAINT LEVEL
#func saint_level_allies():
#	return {2: Saint, 4: Assassin}
#	
#func saint_level_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(3)
#	phase.add_wave({Vector2(5, 4): make(Drummer, 4, [poisonous]), Vector2(4, 6): make(Fortifier, 4), 
#	Vector2(5, 6): make(Grunt, 3), Vector2(4, 4): make(Grunt, 4, [poisonous]),
#	Vector2(6, 7): make(Grunt, 2)})
#	phase.add_reinforcements({Vector2(5, 5): make(Grunt, 2, [poisonous])})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#	
#func saint_level_extras():
#	var complex_tooltip1 = [{"coords":Vector2(2, 7), "text":""}, {"coords":Vector2(3, 7), "text": ""}, {"coords":Vector2(4, 8), "text": ""}, {"coords":Vector2(4, 6), "text": ""}]
#	var complex_tooltip2 = [{"coords":Vector2(3, 7), "text":""}, {"coords":Vector2(4, 8), "text": ""}, {"coords":Vector2(4, 6), "text": ""}, 
#	{"coords":Vector2(4, 7), "text": ""},  {"coords":Vector2(4, 6), "text": ""}, {"coords":Vector2(5, 8), "text": ""}]
#	var complex_tooltip3 = [{"coords":Vector2(5, 9), "text":""}, {"coords":Vector2(6, 9), "text": ""}, {"coords":Vector2(6, 8), "text": ""}, 
#	{"coords":Vector2(5, 8), "text": ""},  {"coords":Vector2(4, 8), "text": ""}, {"coords":Vector2(5, 7), "text": ""}]
#	
#	var saint_level_instructions = [
#	make_complex_tip("The Saint is at your service. The Saint is a Pivot Unit, meaning its Inspire ability, Protect, always triggers after it moves.", "Activate Inspire: Protect.", complex_tooltip1),
#	make_complex_tip("The Saint's passive ability is Purify. When it moves to a tile, the Saint removes all special effects of adjacent enemies if another Player Unit is already adjacent to the enemy.", "Purify an enemy.", complex_tooltip2),
#	make_complex_tip("The Saint can also support allies with Intervention, moving them backwards one space.", "Use Intervention.", complex_tooltip3),
#	]
#	return {"instructions":saint_level_instructions, "free_deploy":false}
#
#func saint_level():
#	return LevelTypes.RoomSeal.new(saint_level_allies(), saint_level_enemies(), level9_ref, saint_level_extras())
#
#var saint_level_ref = funcref(self, "saint_level")
#
#
#LEVEL 8
#func level8_allies():
#	return {3: Archer, 2: Cavalier, Vector2(3, 7): Berserker, 4: Pyromancer}
#	
#func level8_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(3)
#	phase.add_wave({Vector2(2, 3): make(Fortifier, 3), Vector2(4, 4): make(Fortifier, 2), Vector2(1, 2): make(Grower, 2), 
#	Vector2(5, 5): make(Grunt, 5), Vector2(1, 3): make(Drummer, 4), Vector2(3, 5): make(Grunt, 4, [poisonous]), 
#	Vector2(4, 3): make(Grunt, 4), Vector2(6, 5): make(Grower, 2, [shield]), Vector2(0, 4): make(Grunt, 3, [shield]),
#	Vector2(3, 2): make(Grower, 2)})
#	phase.add_reinforcements({Vector2(1, 3): make(Grower, 2), Vector2(4, 6): make(Fortifier, 2)})
#	phase.add_reinforcements({Vector2(1, 6): make(Grunt, 4), Vector2(6, 6): make(Drummer, 2), Vector2(4, 4): make(Grunt, 3, [shield])})
#	var phase2 = EnemyWrappers.CuratedPhase.new(3)
#	phase2.add_wave({Vector2(3, 5): make(Fortifier, 3), Vector2(3, 4): make(Drummer, 4, [shield]), Vector2(3, 3): make(Grunt, 5, [poisonous]),
#	Vector2(1, 3): make(Grunt, 5, shield), Vector2(1, 2): make(Drummer, 2, [shield]), Vector2(4, 4): make(Grower, 3), Vector2(4, 5): make(Fortifier, 3),
#	Vector2(5, 7): make(Drummer, 3), Vector2(4, 7): make(Fortifier, 2, [poisonous])})
#	phase2.add_reinforcements({Vector2(0, 5): make(Grunt, 3, [poisonous]), Vector2(0, 2): make(Drummer, 2)})
#	phase2.add_reinforcements({Vector2(2, 5): make(Grunt, 3), Vector2(3, 6): make(Fortifier, 2)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase, phase2])
#	
#func level8_extras():
#	var level8_instructions = [
#	make_tip("Enemies now have modifier abilities! Hold Tab over units to learn about them.", "", null, ""),
#	]
#	return {"instructions":level8_instructions}
#
#func level8():
#	return LevelTypes.Defend.new(level8_allies(), level8_enemies(), 7, saint_level_ref, level8_extras())
#
#var level8_ref = funcref(self, "level8")
#
#
#
#PYROMANCER LEVEL
#func pyromancer_level_allies():
#	return {3: Pyromancer}
#	
#func pyromancer_level_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(3)
#	phase.add_wave({Vector2(1, 4): make(Grunt, 3), Vector2(2, 5): make(Grunt, 3), 
#	Vector2(3, 6): make(Grunt, 3), Vector2(4, 6): make(Grunt, 3), Vector2(5, 6): make(Grunt, 3)})
#	phase.add_reinforcements({Vector2(4, 4): make(Grunt, 3), Vector2(4, 3): make(Grunt, 3), Vector2(3, 2): make(Grunt, 3)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#	
#func pyromancer_level_extras():
#	var pyromancer_level_instructions = [
#	make_tip("The Pyromancer is a damage focused unit. It throws a Fire Bomb from range, inflicting Wildfire.", "Light stuff on fire.", Vector2(3, 6), ""),
#	make_tip("When inflicted, Wildfire will spread to an adjacent enemy at random. In addition, enemies inflicted are burned, dealing 1 damage each turn.", "Clean up.", null, ""),
#	make_tip("The Pyromancer cannot move and throw a Fire Bomb in the same turn, so plan carefully.", "", null, ""),
#	]
#	return {"instructions":pyromancer_level_instructions, "free_deploy":false}
#
#func pyromancer_level():
#	return LevelTypes.RoomSeal.new(pyromancer_level_allies(), pyromancer_level_enemies(), level8_ref, pyromancer_level_extras())
#
#var pyromancer_level_ref = funcref(self, "pyromancer_level")
#	
#
#LEVEL 7
#func level7_allies():
#	return {3: Archer, 2: Cavalier, Vector2(3, 7): Berserker, 4: Assassin}
#	
#func level7_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(3)
#	phase.add_wave({Vector2(0, 1): make(Grunt, 3), Vector2(1, 1): make(Grunt, 3), Vector2(1, 3): make(Grunt, 4), 
#	Vector2(2, 4): make(Grunt, 3), Vector2(4, 4): make(Grunt, 6), Vector2(5, 5): make(Grunt, 3),
#	Vector2(5, 3): make(Grunt, 3)})
#	phase.add_reinforcements({Vector2(1, 3): make(Grunt, 3), Vector2(3, 3): make(Grunt, 6), Vector2(5, 6): make(Grunt, 3)})
#	phase.add_reinforcements({Vector2(1, 3): make(Grower, 3), Vector2(4, 3): make(Grower, 4), Vector2(4, 6): make(Fortifier, 2)})
#	var phase2 = EnemyWrappers.CuratedPhase.new(1)
#	phase2.add_wave({Vector2(1, 6): make(Grunt, 2), Vector2(3, 2): make(Grower, 2), Vector2(3, 3): make(Fortifier, 3), 
#	Vector2(4, 4): make(Grunt, 5), Vector2(0, 0): make(Grower, 2), Vector2(4, 6): make(Grunt, 4)}) 
#	return EnemyWrappers.FinitePhasedWrapper.new([phase, phase2])
#	
#func level7_extras():
#	var level7_instructions = [
#	make_tip("From here on out, you can choose where to place your Units at the start of the game.", "Deploy your Units, then press Space to Start.", null, ""),
#	make_tip("At the top of the screen, you'll see a new Win Condition. If you keep an enemy from passing for 9 turns, you win.", "Defend for 9 turns.", null, ""),
#	make_tip("Regardless of the explicit Win Condition, you can always clear the board of enemies to win.", "Alternate objective: clear the board.", null, ""),
#	make_tip("Remember to hold Tab over new units to learn about their abilities.", "", null, "")
#	]
#	return {"instructions":level7_instructions}
#
#func level7():
#	return LevelTypes.Defend.new(level7_allies(), level7_enemies(), 9, pyromancer_level_ref, level7_extras())
#
#var level7_ref = funcref(self, "level7")
#
#var level7_enemies = [
#{Vector2(7, 6): make(Drummer, 2), 1: make(Grunt, 4), 2: make(Grunt, 3), 4: make(Grunt, 2), 5: make(Grunt, 4), 6: make(Grunt, 2)},
#{3: make(Fortifier, 2), 4: make(Grunt, 5), 5: make(Grower, 2), 6: make(Fortifier, 5)},
#{0: make(Grower, 1), 3: make(Grunt, 3), 4: make(Drummer, 2), 6: make(Grower, 1), 8: make(Grower, 1)},
#{2: make(Grunt, 6), 5: make(Grower, 1), 6: make(Grunt, 2), 7: make(Grunt, 3)},
#{0: make(Grunt, 4), 3: make(Fortifier, 3), 4: make(Grower, 1), 5: make(Drummer, 4)},
#{1: make(Grunt, 4), 2: make(Grunt, 3), 4: make(Grunt, 4), 5: make(Grower, 3)},
#{2: make(Grunt, 2), 3: make(Drummer, 1), 5: make(Fortifier, 2), 7: make(Grunt, 2)}
#]
#
#ASSASSIN LEVEL
#
#func assassin_level_allies():
#	return {3: Assassin}
#	
#func assassin_level_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(3)
#	phase.add_wave({Vector2(3, 6): make(Grunt, 4), Vector2(2, 3): make(Grunt, 4)})
#	phase.add_reinforcements({Vector2(1, 6): make(Grunt, 9), Vector2(4, 8): make(Grunt, 9), 5: make(Grunt, 5)})
#	phase.add_reinforcements({Vector2(3, 3): make(Grunt, 4), Vector2(0, 0): make(Grunt, 4), Vector2(2, 1): make(Grunt, 5)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#	
#func assassin_level_extras():
#	var complex_tooltip1 = [{"coords":Vector2(3, 5), "text":""}, {"coords":Vector2(3, 7), "text": ""}, {"coords":Vector2(3, 6), "text": ""}, {"coords":Vector2(2, 4), "text": ""}]
#	var complex_tooltip2 = [{"coords":Vector2(2, 3), "text":""}, {"coords":Vector2(4, 4), "text": ""}, 
#	{"coords":Vector2(5, 9), "text": ""}, {"coords":Vector2(5, 4), "text": ""}, 
#	{"coords":Vector2(4, 4), "text": "If the Assassin is on cooldown, its passive also activates Bloodlust!"},
#	{"coords":Vector2(3, 3), "text": ""}]
#	var assassin_level_instructions = [
#	make_tip("The Assassin is now at your disposal. It attacks by backstabbing.", "Backstab an Enemy Unit.", Vector2(3, 6), ""),
#	make_complex_tip("The Assassin is a mobile unit. After killing an enemy, it gains Bloodlust, allowing it to act again and deal +2 damage on its next Backstab.", "Kill two enemies this turn.", complex_tooltip1),
#	make_complex_tip("If an adjacent enemy is attacked and isn't killed, the Assassin's passive allows it to follow up with its own attack.", "Use the Assassin's passive.", complex_tooltip2),
#	make_tip("", "Clean up (Can you do it in one turn?).", null, "")
#	]
#	var assassin_level_reinforcements = {3: {5: Cavalier}}
#	return {"instructions":assassin_level_instructions, "reinforcements":assassin_level_reinforcements, "free_deploy":false}
#
#
#func assassin_level():
#	return LevelTypes.RoomSeal.new(assassin_level_allies(), assassin_level_enemies(), level7_ref, assassin_level_extras())
#
#var assassin_level_ref = funcref(self, "assassin_level")
#
#
#
#LEVEL 6
#func level6_allies():
#	return {2: Archer, 4:Cavalier}
#	
#func level6_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(3)
#	phase.add_wave({Vector2(3, 6): make(Grunt, 7), Vector2(3, 5): make(Grunt, 2)})
#	phase.add_reinforcements({Vector2(1, 3): make(Grunt, 3), Vector2(3, 3): make(Grunt, 2), Vector2(4, 2): make(Grunt, 2), Vector2(5, 3): make(Grunt, 2)})
#	phase.add_reinforcements({Vector2(1, 7): make(Grunt, 9), Vector2(5, 9): make(Grunt, 9)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#	
#func level6_extras():
#	var complex_tooltip1 = [{"coords":Vector2(2, 7), "text":""}, {"coords":Vector2(3, 8), "text": ""}, {"coords":Vector2(4, 8), "text": ""}, {"coords":Vector2(3, 7), "text": ""}]
#	var complex_tooltip2 = [{"coords":Vector2(3, 7), "text":""}, {"coords":Vector2(3, 2), "text": ""}, {"coords":Vector2(3, 8), "text": ""}, {"coords":Vector2(3, 7), "text": ""}]
#	
#	var level6_instructions = [
#	make_complex_tip("A Unit cannot be pushed if there's something else behind it.", "Block the Enemy Units.", complex_tooltip1),
#	make_complex_tip("Enemies cannot be summoned past the furthest back Player Unit.", "Move your units forward to cancel the summons.", complex_tooltip2),
#	make_tip("Look to move your Units forward in order to reduce the area in which Enemies can be summoned.", "Clean up.", null, "")
#	]
#	return {"instructions":level6_instructions, "free_deploy":false}
#
#func level6():
#	return LevelTypes.RoomSeal.new(level6_allies(), level6_enemies(), assassin_level_ref, level6_extras())
#
#var level6_ref = funcref(self, "level6")
#
#
#LEVEL 5
#func level5_allies():
#	return {3:Archer}
#	
#func level5_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(2)
#	phase.add_wave({Vector2(6, 5): make(Grunt, 3), 2: make(Grunt, 3)})
#	phase.add_reinforcements({Vector2(2, 3): make(Grunt, 5)})
#	var phase2 = EnemyWrappers.CuratedPhase.new(3)
#	phase2.add_wave({1: make(Grunt, 5), 3: make(Grunt, 3), 2: make(Grunt, 2), 5: make(Grunt, 6)})
#	phase2.add_reinforcements({Vector2(3, 3): make(Grunt, 4), Vector2(2, 3): make(Grunt, 3)})
#	phase2.add_reinforcements({Vector2(3, 4): make(Grunt, 3)})
#	var phase3 = EnemyWrappers.CuratedPhase.new(1)
#	phase3.add_wave({Vector2(1, 5): make(Grunt, 6), Vector2(3, 5): make(Grunt, 6), Vector2(4, 6): make(Grunt, 6),
#	Vector2(5, 5): make(Grunt, 4), Vector2(3, 4): make(Grunt, 4)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase, phase2, phase3])
#	
#func level5_extras():
#	var level5_instructions = [
#	make_tip("The Archer can attack from range and is able to shoot along diagonal lines.", "Attack diagonally.", Vector2(6, 5), ""),
#	make_tip("When the Archer moves, its passive causes it to automatically shoot directly North.", "Use the Archer's passive.", Vector2(2, 7), ""),
#	make_tip("A large group of incoming enemies is called a Wave. Check the top of the screen to see when the next Wave appears.", "", null, ""),
#	make_tip("When an enemy is summoned onto the board, if the tile is already occupied by a Player Unit, the Player Unit is KOed. If the tile is occupied by an Enemy, it becomes stronger.", "", null, ""),
#	make_tip("If a Player Unit is KOed, move another Player Unit adjacent to the tile it was KOed on to revive it. Revived units cannot act on the turn they are revived.", "Clear all enemies before the next Wave appears.", null, ""),
#	make_tip("The Archer is a Step Move Unit, meaning it is blocked by other pieces while moving. The Berserker and Cavalier are Leap Move Pieces, and can leap over other pieces.", "", null, ""),
#	make_tip("Keep in mind that the Archer's shots are blocked by other Player Units.", "", null, "")
#	]
#	var level5_reinforcements = {3: {0: Berserker, 6: Cavalier}}
#	return {"instructions":level5_instructions, "reinforcements":level5_reinforcements, "free_deploy":false}
#
#func level5():
#	return LevelTypes.RoomSeal.new(level5_allies(), level5_enemies(), level6_ref, level5_extras())
#
#var level5_ref = funcref(self, "level5")
#
#LEVEL 4
#func level4_allies():
#	return {3: Berserker, 6: Cavalier}
#	
#func level4_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(99)
#	phase.add_wave({Vector2(2, 6): make(Grunt, 4), Vector2(4, 7): make(Grunt, 3), Vector2(5, 8): make(Grunt, 3),
#	Vector2(2, 3): make(Grunt, 3), 
#	Vector2(3, 3): make(Grunt, 5), Vector2(4, 4):make(Grunt, 2),
#	Vector2(1, 3): make(Grunt, 2),
#	1: make(Grunt, 5), 2: make(Grunt, 3), 4:make(Grunt, 2)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#	
#func level4_extras():
#	var complex_tooltip1 = [{"coords":Vector2(3, 8), "text":""}, {"coords":Vector2(2, 6), "text": "Kill an enemy to trigger a Inspire Effect."}, {"coords":Vector2(6, 9), "text": "The next Unit to act receives the Inspire Effect."}, {"coords":Vector2(3, 6), "text": "The next Unit to act receives the Inspire Effect."}]
#	var level4_instructions = [
#	make_complex_tip("If a Player Unit gets a kill, it activates its Inspire Ability, which gives a bonus effect to the next Player Unit that acts this turn.", "Activate a Inspire.", complex_tooltip1),
#	make_tip("Press Tab over a Player Unit to see its Inspire Ability.", "Clean up.", null, ""),
#	make_tip("Each Player Unit can move once per turn. Right Click or press Escape to deselect a Player Unit. To quickly end your turn, press SPACE." \
#	,"", null, ""),
#	]
#	return {"instructions":level4_instructions, "free_deploy":false}
#
#func level4():
#	return LevelTypes.RoomSeal.new(level4_allies(), level4_enemies(), level5_ref, level4_extras())
#
#var level4_ref = funcref(self, "level4")
#
#
#LEVEL 3
#func level3_allies():
#	return {Vector2(3, 7): Berserker}
#	
#	
#func level3_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(99)
#	phase.add_wave({Vector2(3, 2) : make(Grunt, 2), Vector2(2, 3): make(Grunt, 1), 
#	Vector2(3, 3) :make(Grunt, 8), Vector2(3, 5): make(Grunt, 4), 
#	Vector2(3, 6): make(Grunt, 6)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#	
#func level3_extras():
#	var level3_instructions = [
#	
#	make_tip("Enemies will push Player Units forward on their turn. If a Player Unit is pushed off the map, it is KOed.", \
#	"Don't let the Berserker get KOed.", Vector2(3, 6), ""),
#	make_tip("If a Player Unit is pushed by an Enemy with Health equal to or greater than its Armor, it is also KOed. You LOSE if all Player Units are KOed.", "Don't lose.", null, ""),
#	make_tip("Remember that the Berserker stuns enemies with its Passive. If you need a refresher on a Unit, hold Tab over it for a summary.", "" , null, ""),
#	]
#	return {"instructions":level3_instructions, "free_deploy":false}
#
#func level3():
#	return LevelTypes.RoomSeal.new(level3_allies(), level3_enemies(), level4_ref, level3_extras())
#
#var level3_ref = funcref(self, "level3")
#
#
#LEVEL 2
#func level2_allies():
#	return {3: Cavalier}
#	
#func level2_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(99)
#	phase.add_wave({Vector2(3, 6): make(Grunt, 5), Vector2(3, 5): make(Grunt, 5), Vector2(3, 4): make(Grunt, 2)})
#	phase.add_reinforcements({1: make(Grunt, 2), 2:make(Grunt, 2)})
#	phase.add_reinforcements({3: make(Grunt, 2)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#
#func level2_extras():
#	var level2_instructions = [
#		make_tip("The Cavalier can run through enemies and Trample them.", \
#		"Move the Cavalier behind enemy lines.", Vector2(3, 2), ""),
#		make_tip("The Cavalier does 2 damage to each enemy he Tramples through.", \
#		"The Cavalier can unleash his direct attack, Charge, when there are no Units (Enemy or Friendly) blocking his path to an enemy. Charge at the enemy!", Vector2(3, 6), ""),
#		make_tip("Charge deals 1 damage for each tile travelled to the first enemy it hits, and the enemy behind it.", "Eliminate all remaining enemies.", null, ""),
#	]
#	return {"instructions":level2_instructions, "free_deploy":false}
#
#func level2():
#	return LevelTypes.RoomSeal.new(level2_allies(), level2_enemies(), level3_ref, level2_extras())
#
#var level2_ref = funcref(self, "level2")
#
#
#
#LEVEL 1
#func level1_allies():
#	return {3: Berserker}
#	
#func level1_enemies():
#	var phase = EnemyWrappers.CuratedPhase.new(99)
#	phase.add_wave({ Vector2(3, 3): make(Grunt, 7), Vector2(0, 0): make(Grunt, 2)})
#	phase.add_reinforcements({0: make(Grunt, 2)})
#	phase.add_reinforcements({2: make(Grunt, 2), 3: make(Grunt, 6), 4: make(Grunt, 2)})
#	phase.add_reinforcements({4: make(Grunt, 2)})
#	return EnemyWrappers.FinitePhasedWrapper.new([phase])
#
#func level1_extras():
#	var complex_tooltip1 = [{"coords":Vector2(3, 8), "text":"Click on the Berserker to select it."}, {"coords":Vector2(3, 6), "text": "Click on this tile to move the Berserker here."}]
#	var complex_tooltip2 = [{"coords":Vector2(3, 6), "text":"Select the Berserker."}, {"coords":Vector2(3, 4), "text":"Select the enemy to attack it."}]
#	var level1_instructions = [
#		make_complex_tip("Clear the board of enemies to WIN.", "Move the Berserker towards the enemies.", complex_tooltip1),
#		make_complex_tip("Enemies move down one tile each turn. If an enemy moves off the bottom of the map, you LOSE.",  "Attack the nearby enemy.", complex_tooltip2),
#		make_tip("The Berserker's direct attack deals 4 damage.",  "Finish off the enemy.", Vector2(3, 5), ""),
#		make_tip("When the Berserker kills an enemy, it lands on their tile. ", \
#		 "The next group of enemies is outside of direct attack range. Move the Berserker next to them to trigger its passive effect, Ground Slam.", \
#		 Vector2(1, 3), ""),
#		make_tip("When the Berserker lands on an unoccupied tile, Ground Slam deals 2 damage to adjacent enemies and stuns them, keeping them from moving.", \
#		"Finish off the remaining enemies to beat the level.", null, "")
#	]
#	return {"instructions":level1_instructions, "free_deploy":false}
#	
#func level1():
#	return LevelTypes.RoomSeal.new(level1_allies(), level1_enemies(), level2_ref, level1_extras())
#	
#var level1_ref = funcref(self, "level1")
#
