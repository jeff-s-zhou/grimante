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

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")
const Cavalier = preload("res://PlayerPieces/CavalierPiece.tscn")
const Archer = preload("res://PlayerPieces/ArcherPiece.tscn")
const Knight = preload("res://PlayerPieces/KnightPiece.tscn")
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

#var available_unit_roster = get_node("/root/global").available_unit_roster

func load_level(file_name):
	var enemy_waves = {}
	for i in range(0, 9): #TODO: don't hardcode this in, so you can have varied game lengths
		#initialize a subdict for each wave
		enemy_waves[i] = {}

	var save = File.new()
	if !save.file_exists("user://" + file_name):
		return #Error!  We don't have a save to load

	# Load the file line by line and process that dictionary to restore the object it represents
	var current_line = {} # dict.parse_json() requires a declared dict.
	save.open("user://" + file_name, File.READ)
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
	
	
func make_tip(tip_text, objective_text, arrow_coords, text):
	return {"tip_text":tip_text, "objective_text": objective_text, "tooltip": {"coords":arrow_coords, "text":text}}

#used when the tooltip changes upon clicking
func make_complex_tip(tip_text, objective_text, tooltips):
	return {"tip_text":tip_text, "objective_text": objective_text, "tooltips": tooltips}
	
func sandbox_allies():
	return [Assassin, Berserker, Cavalier] #2: Cavalier, 3: Archer, 4: Assassin}

func sandbox_enemies():
	var turn_power_levels = [1300, 0, 500, 0, 600, 0, 650, 0, 700]
	return EnemyWrappers.FiniteGeneratedWrapper.new(turn_power_levels)
	
func sandbox_enemies2():
	var turn_power_levels = [300, 0, 0, 0, 0]
	var enemies = [{Vector2(3, 4): make(Drummer, 4)}]
	#var enemies = load_level("level2.save")
	return EnemyWrappers.FiniteCuratedWrapper.new(turn_power_levels, enemies)
	
func sandbox_extras():
	var tutorial = TutorialPrototype.instance()

	var turn0_player_start_rule = RulePrototype.instance()
	turn0_player_start_rule.initialize(["Clear the board of enemies to win."])
	tutorial.add_player_turn_start_rule(turn0_player_start_rule, 0)
	
	var forced_action = ForcedActionPrototype.instance()
	forced_action.initialize(Vector2(3, 7), " Click on the Berserker to select it.", Vector2(3, 5), "Click on this tile to move the Berserker here.")
	tutorial.add_forced_action(forced_action, 0)
	
	var turn0_enemy_rule = RulePrototype.instance()
	turn0_enemy_rule.initialize(["Enemies move down one tile each turn.", "If an enemy exits from the bottom of the board, you lose."])
	tutorial.add_enemy_turn_end_rule(turn0_enemy_rule, 0)
	
	#return {"shifting_sands_tiles": {Vector2(3, 6): 4}, "tutorial":tutorial}
	return {"tutorial":tutorial, "free_deploy":false}
	
func sandbox_extras2():
	return {"required_units":{1: Cavalier, 2: Berserker, 3: Pyromancer, 4: Corsair, 5: Archer}}

func sandbox_level():
	return LevelTypes.RoomSeal.new(sandbox_allies(), sandbox_enemies(), null, sandbox_extras2())#, null, sandbox_extras()) 

var sandbox_level_ref = funcref(self, "sandbox_level")
#
#
#LEVEL 10
#func level10_allies():
#	return {1: Archer, 2:Berserker, 3:Cavalier, 4:Saint, 5: Pyromancer}
#
#func level10_enemies():
#	var phase1_unit_roster = {0: Grunt, 1: Fortifier, 2: Grower, 3: Drummer, 4: Melee}
#	var phase1_modifier_roster = {0: enemy_modifiers["Shield"], 1: enemy_modifiers["Poisonous"], 2: enemy_modifiers["Cloaked"]}
#	var phase3_modifier_roster = {0: enemy_modifiers["Shield"], 1: enemy_modifiers["Poisonous"]}
#	var phase3_unit_roster = {0: Grunt, 1: Fortifier, 2: Grower, 3: Drummer, 4: Melee, 5: Ranged}
#	
#	var phase = EnemyWrappers.ProcGenPhase.new(1400, 300, phase1_unit_roster, phase1_modifier_roster)
#	var phase2 = EnemyWrappers.ProcGenPhase.new(1400, 300, phase1_unit_roster, phase1_modifier_roster)
#	var phase3 = EnemyWrappers.FinalProcGenPhase.new(1500, 300, phase3_unit_roster, phase3_modifier_roster)
#	return EnemyWrappers.InfinitePhasedWrapper.new([phase, phase2, phase3])
#	
#func level10_extras():
#	var level10_instructions = [
#	make_tip("And here's where I ran out of time. On the bright side, this level and the previous level are procedurally generated so you can replay them!", "", null, ""),
#	]
#	return {"instructions":level10_instructions}
#
#func level10():
#	return LevelTypes.Defend.new(level10_allies(), level10_enemies(), 12, null, level10_extras())
#
#var level10_ref = funcref(self, "level10")	
#
#
#LEVEL 9
#func level9_allies():
#	return {1: Archer, 2:Berserker, 3:Cavalier, 4:Saint, 5: Assassin}
#
#func level9_enemies():
#	var phase1_unit_roster = {0: Grunt, 1: Fortifier, 2: Grower, 3: Drummer}
#
#	var phase1_modifier_roster = {0: enemy_modifiers["Shield"], 1: enemy_modifiers["Poisonous"]}
#	
#	var phase2_modifier_roster = {0: enemy_modifiers["Shield"], 1: enemy_modifiers["Poisonous"], 2: enemy_modifiers["Cloaked"]}
#	
#	var phase3_unit_roster = {0: Grunt, 1: Fortifier, 2: Grower, 3: Drummer, 4: Melee}
#	
#	var phase = EnemyWrappers.ProcGenPhase.new(1400, 300, phase1_unit_roster, phase1_modifier_roster)
#	var phase2 = EnemyWrappers.ProcGenPhase.new(1400, 300, phase1_unit_roster, phase2_modifier_roster)
#	var phase3 = EnemyWrappers.FinalProcGenPhase.new(1500, 300, phase3_unit_roster, phase1_modifier_roster)
#	return EnemyWrappers.InfinitePhasedWrapper.new([phase, phase2, phase3])
#	
#func level9_extras():
#	var level9_instructions = [
#	make_tip("Now that you have access to 5 units, you can use Inspire Finishers. When all 5 units trigger their Inspire Effect in a turn, the Player is allowed to reactivate 1 unit, giving it all 3 types of Inspire Bonuses.", "Use a Inspire Finisher during this level.", null, ""),
#	]
#	return {"instructions":level9_instructions}
#
#func level9():
#	return LevelTypes.Timed.new(level9_allies(), level9_enemies(), 12, level10_ref, level9_extras())
#
#var level9_ref = funcref(self, "level9")	
#
#
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
