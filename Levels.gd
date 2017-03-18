extends Node

var EnemyWrappers = load("res://EnemyWrappers.gd").new()
var LevelTypes = load("res://LevelTypes.gd").new()

const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Fortifier = preload("res://EnemyPieces/FortifierPiece.tscn")
const Grower = preload("res://EnemyPieces/GrowerPiece.tscn")
const Drummer = preload("res://EnemyPieces/DrummerPiece.tscn")
const Melee = preload("res://EnemyPieces/MeleePiece.tscn")
const Ranged = preload("res://EnemyPieces/RangedPiece.tscn")

const King = preload("res://EnemyPieces/KingPiece.tscn")

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")
const Cavalier = preload("res://PlayerPieces/CavalierPiece.tscn")
const Archer = preload("res://PlayerPieces/ArcherPiece.tscn")
const Knight = preload("res://PlayerPieces/KnightPiece.tscn")
const Assassin = preload("res://PlayerPieces/AssassinPiece.tscn")
const Stormdancer = preload("res://PlayerPieces/StormdancerPiece.tscn")
const Pyromancer = preload("res://PlayerPieces/PyromancerPiece.tscn")
const FrostKnight = preload("res://PlayerPieces/FrostKnightPiece.tscn")
const Saint = preload("res://PlayerPieces/SaintPiece.tscn")

var enemy_modifiers = load("res://constants.gd").new().enemy_modifiers
var shield = enemy_modifiers["Shield"]
var poisonous = enemy_modifiers["Poisonous"]
var cloaked = enemy_modifiers["Cloaked"]

func make(prototype, health, modifiers=null):
	return {"prototype": prototype, "health": health, "modifiers":modifiers}
	
	
func make_tip(tip_text, objective_text, arrow_coords, text):
	return {"tip_text":tip_text, "objective_text": objective_text, "tooltip": {"coords":arrow_coords, "text":text}}

#used when the tooltip changes upon clicking
func make_complex_tip(tip_text, objective_text, tooltips):
	return {"tip_text":tip_text, "objective_text": objective_text, "tooltips": tooltips}
	
func sandbox_allies():
	return {1: Cavalier, 2: Berserker, 3: Archer, 4: Assassin, 5: Stormdancer}
#
#class SandboxPowerGenerator:
#	var power_level = 200
#	func get_next():
#		print("getting next power level: " + str(self.power_level))
#		self.power_level += 20
#		return self.power_level
#		
#	func reset():
#		self.power_level = 200
#		
#var finite_power_levels = [400, 450, 500, 550, 550]

func sandbox_phase1():
	return EnemyWrappers.ProcGenPhase.new(1400, 200)
func sandbox_phase2():
	return EnemyWrappers.ProcGenPhase.new(1600, 250)
func sandbox_phase3():
	return EnemyWrappers.ProcGenPhase.new(1700, 300)
	
func curated_sandbox_phase1():
	var phase = EnemyWrappers.CuratedPhase.new(3)
	phase.add_wave({Vector2(3, 5): make(Ranged, 3), Vector2(0, 0): make(Grunt, 3)})
	phase.add_reinforcements({Vector2(0, 0): make(Grunt, 3), Vector2(2, 3): make(Grunt, 3), Vector2(3, 3): make(Grunt, 3), Vector2(3, 5): make(Ranged, 3)})
	phase.add_reinforcements({Vector2(0, 0): make(Grunt, 3)})
	return phase

func sandbox_enemies():
	return EnemyWrappers.InfinitePhasedWrapper.new([sandbox_phase1(), sandbox_phase2(), sandbox_phase3()])
	
func sandbox_enemies2():
	return EnemyWrappers.InfinitePhasedWrapper.new([curated_sandbox_phase1()])

func sandbox_level():
	return LevelTypes.RoomSeal.new(sandbox_allies(), sandbox_enemies(), null) #, sandbox_extras)

var sandbox_level_ref = funcref(self, "sandbox_level")

#LEVEL 8
#var level8_allies = {1: Stormdancer, 2: Cavalier, 3:Archer, 4:Assassin, 5: Berserker}
#
#var level8_enemies = [
#{Vector2(1, 3): make(Grunt, 3), Vector2(5, 5): make(Drummer, 2), Vector2(7, 6): make(Drummer, 2)},
#{1: make(Grunt, 4), 2: make(Grunt, 3), 3: make(Fortifier, 4), 4: make(Drummer, 6, [poisonous]), 6: make(Grower, 2)},
#{4: make(Grower, 2, [shield]), 5: make(Drummer, 4, [shield]), 6: make(Grunt, 3), 7: make(Grunt, 2)},
#{0: make(Grower, 2), 2: make(Drummer, 2), 3: make(Fortifier, 3), 5: make(Grunt, 5), 8: make(Drummer, 2)},
#{1: make(Grower, 2, [shield]), 3: make(Grunt, 5, [poisonous]), 4: make(Grunt, 4, [poisonous]), 7: make(Grunt, 4)},
#{0: make(Grower, 1), 4: make(Grunt, 7, [shield, poisonous]), 7: make(Drummer, 3, [shield])},
#{2: make(Grunt, 3), 3: make(Fortifier, 4), 4: make(Drummer, 6, [poisonous]), 6: make(Grower, 2)},
#]
#
#
#var level8_instructions = [
#	make_tip("Enemies now have Modifier abilities! Press Tab to read about any new abilities.", "", null, "")
#]
#
#var Level8 = {"allies":level8_allies, "enemies":level8_enemies, "initial_deploy_count":3,
#"instructions":[], "reinforcements":{}, "next_level":null}
#
#
#LEVEL 7
#var level7_allies = {3: Archer, 4: Berserker, 5:Cavalier, 6:Assassin}
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
#var level7_instructions = [
#	make_tip("Remember to press Tab to learn about new units (and Ultimate abilities)!", "", null, "")
#]
#
#var Level7 = {"allies":level7_allies, "enemies":level7_enemies, "initial_deploy_count":3,
#"instructions":level7_instructions, "reinforcements": {}, "next_level":Level8}
#
#LEVEL 6
#var level6_allies = {Vector2(4, 3): Berserker}
#
#var level6_enemies = [
#	{  Vector2(4, 9):make(Grunt, 2), Vector2(4, 8):make(Grunt, 2), Vector2(4, 7):make(Grunt, 3), Vector2(4, 6):make(Grunt, 5), },
#	{  3: make(Grunt, 3), 4: make(Grunt, 2)}
#]
#
#var level6_instructions = [
#	make_tip("Select a unit and then hold Left Click on it to activate its Ultimate Ability.", "Use your ultimate (animation not yet implemented sorry!).", null, ""),
#	make_tip("With some exceptions, Ultimates may only be used once per level.", "", null, "")
#]
#
#var Level6 = {"allies": level6_allies, "enemies":level6_enemies, "initial_deploy_count":3,
#"instructions":level6_instructions, "reinforcements": {}, "next_level":Level7, "flags":["ultimates_enabled_flag"]}
#
#LEVEL 5
#
#var level5_allies = {3: Berserker, 4: Cavalier, 5:Archer}
#
#var level5_enemies = [
#	{2: make(Grunt, 5), 4: make(Grunt, 5), 6:make(Grunt, 3), 7:make(Grunt, 4)},
#	{1: make(Grunt, 3), 3: make(Grunt, 6), 5:make(Grunt, 4), 6:make(Grunt, 4)},
#	{1: make(Grunt, 3), 2: make(Grunt, 3), 4:make(Grunt, 2), 5:make(Grunt, 3)},
#	{3: make(Grower, 1), 4: make(Fortifier, 2), 6:make(Grower, 1)},
#	{0: make(Grower, 1), 3: make(Grunt, 4), 4:make(Fortifier, 3), 5:make(Grunt, 5)},
#	{2: make(Grunt, 4), 3: make(Fortifier, 3), 4:make(Grower, 1), 5:make(Grunt, 5)},
#	{2: make(Fortifier, 1), 3: make(Grower, 3), 4:make(Fortifier, 5), 5:make(Grunt, 5)}
#]
#
#var level5_instructions = [
#make_tip("", "", null, ""),
#make_tip("Elite Enemies with special abilities are colored Grey.", "Hold Tab over them to learn their abilities.", null, "")
#]
#
#var Level5 = {"allies": level5_allies, "enemies":level5_enemies, "initial_deploy_count":3,
#"instructions":level5_instructions, "reinforcements": {}, "next_level":Level6}
#	
#LEVEL 4
#var level4_allies = {3: Berserker, 4: Cavalier}
#var level4_enemies = [
#{Vector2(7, 7): make(Grunt, 4)},
#{Vector2(3, 4): make(Grunt, 3), Vector2(4, 4): make(Grunt, 4), Vector2(5, 5):make(Grunt, 2)},
#{Vector2(1, 3): make(Grunt, 3), Vector2(2, 4): make(Grunt, 2)},
#{2: make(Grunt, 5), 3: make(Grunt, 3), 4: make(Grunt, 6), 5:make(Grunt, 2)},
#{2: make(Grunt, 4), 4: make(Grunt, 2), 5:make(Grunt, 3)},
#{2: make(Grunt, 2), 3: make(Grunt, 4), 7:make(Grunt, 3)}
#]
#var level4_instructions = [
#make_tip("Each Player Unit can move once per turn. To quickly end your turn, you can press END TURN on the sidebar." \
#,"", null, ""),
#make_tip("Right click or press Escape to de-select a Player Unit.", "", null, ""),
#make_tip("The Archer has arrived! Hold Tab over the Archer learn how to use this Unit.", "", null, ""),
#make_tip("The Archer has 0 Armor, so if it gets pushed it's KOed. Units with 0 Armor are partially transparent.", "Win", null, ""),
#]
#
#var level4_reinforcements = {3:{7: Archer}}
#
#var Level4 = {"allies": level4_allies, "enemies":level4_enemies, "initial_deploy_count":4,
#"instructions":level4_instructions, "reinforcements": level4_reinforcements, "next_level":Level5}
#
#
#LEVEL 3
#var level3_allies = {3: Berserker}
#var level3_enemies = [
#{Vector2(4, 4) : make(Grunt, 2)},
#{Vector2(3, 5) : make(Grunt, 1), Vector2(4, 5) :make(Grunt, 8)},
#{ Vector2(4, 7): make(Grunt, 4) },
#{Vector2(3, 7): make(Grunt, 2), Vector2(4, 8): make(Grunt, 3), Vector2(5, 8): make(Grunt, 2)},
#{Vector2(3, 8): make(Grunt, 2), Vector2(4, 9): make(Grunt, 2), Vector2(5, 9): make(Grunt, 2)}
#]
#var level3_instructions = [
#make_tip("If you need a refresher on a Unit, hold Tab over a Unit for a summary.", "Smash!", Vector2(4, 8), ""),
#make_tip("Enemies will push Player Units forward. If a Player Unit is pushed off the map, it is KOed.", \
#"Don't let the Berserker get KOed.", null, ""),
#make_tip("You lose a life if an enemy exits from the bottom of the map. You LOSE the game if you lose all lives or all Player Units are KOed.", "Don't lose.", null, "")
#]
#
#var Level3 = {"allies": level3_allies, "enemies":level3_enemies, "initial_deploy_count":5,
#"instructions":level3_instructions, "reinforcements": {}, "next_level":Level4}
#
#LEVEL 2
#var level2_allies = {4: Cavalier}
#var level2_enemies = [
#{Vector2(4, 6): make(Grunt, 6), Vector2(4, 5): make(Grunt, 2), Vector2(4,4): make(Grunt, 2), Vector2(4, 3): make(Grunt, 2)},
#{2: make(Grunt, 2), 3:make(Grunt, 2)},
#{4: make(Grunt, 3)}
#]
#
#var level2_instructions = [
#	make_tip("The Cavalier can run through enemies and Trample them.", \
#	"Move the Cavalier behind enemy lines.", Vector2(4, 2), ""),
#	make_tip("The Cavalier does 2 damage to each enemy he Tramples through.", \
#	"The Cavalier can unleash his direct attack, Charge, when he has an open path to an enemy. Charge at the enemy!", Vector2(4, 7), ""),
#	make_tip("Charge deals 1 damage for each tile travelled.", "Eliminate all remaining enemies.", null, ""),
#]
#var Level2 = {"allies": level2_allies, "enemies":level2_enemies, "initial_deploy_count":1,
#"instructions":level2_instructions, "reinforcements": {}, "next_level":Level3}
#
#
#LEVEL 1
#var level1_allies = {4: Berserker}
#
#var level1_enemies = [
#{ Vector2(4, 4): make(Grunt, 6), 1: make(Grunt, 2), Vector2(1, 1): make(Grunt, 2)},
#{2: make(Grunt, 2)},
#{3: make(Grunt, 2), 4: make(Grunt, 3), 5: make(Grunt, 2)},
#{4: make(Grunt, 2)},
#]
#
#var complex_tooltip1 = [{"coords":Vector2(4, 9), "text":"Click on the Berserker to select it."}, {"coords":Vector2(4, 7), "text": "Click on this tile to move the Berserker here."}]
#var complex_tooltip2 = [{"coords":Vector2(4, 7), "text":"Select the Berserker."}, {"coords":Vector2(4, 5), "text":"Select the enemy to attack it."}]
#
#var level1_instructions = [
#	make_complex_tip("Eliminate all enemies to win.", "Move the Berserker towards the enemies.", complex_tooltip1),
#	make_complex_tip("Enemies move down one tile each turn.",  "Attack the nearby enemy.", complex_tooltip2),
#	make_tip("The Berserker's direct attack deals 3 damage.",  "Finish off the enemy.", Vector2(4, 6), ""),
#	make_tip("When the Berserker kills an enemy, it lands on their tile. ", \
#	 "The next group of enemies is outside of direct attack range. Move the Berserker next to them to trigger its passive effect, Ground Slam.", \
#	 Vector2(2, 4), ""),
#	make_tip("When the Berserker lands on a tile, Ground Slam deals 2 damage to adjacent enemies.", \
#	"Kill the remaining enemies in one move.", null, "")
#]
#
#var Level1 = {"allies":level1_allies, "enemies":level1_enemies, "initial_deploy_count":1, 
#"instructions":level1_instructions, "reinforcements": {}, "next_level": Level2}
#
#



