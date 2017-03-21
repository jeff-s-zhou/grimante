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
	return {3: Berserker} #2: Cavalier, 3: Archer, 4: Assassin}
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
	var phase = EnemyWrappers.CuratedPhase.new(2)
	phase.add_wave({Vector2(3, 5): make(Grunt, 4)})
	phase.add_wave({Vector2(2, 5): make(Grunt, 5)})
	return phase
	
func curated_sandbox_phase2():
	var phase = EnemyWrappers.CuratedPhase.new(3)
	phase.add_wave({Vector2(3, 5): make(Grunt, 6)})
	phase.add_wave({Vector2(2, 5): make(Grunt, 7)})
	phase.add_wave({Vector2(2, 5): make(Grunt, 8)})
	return phase


func sandbox_enemies():
	return EnemyWrappers.InfinitePhasedWrapper.new([sandbox_phase1(), sandbox_phase2(), sandbox_phase3()])
	
func sandbox_enemies2():
	return EnemyWrappers.InfinitePhasedWrapper.new([curated_sandbox_phase1(), curated_sandbox_phase2()])

func sandbox_level():
	return LevelTypes.RoomSeal.new(sandbox_allies(), sandbox_enemies2(), null) #, sandbox_extras)

var sandbox_level_ref = funcref(self, "sandbox_level")


#LEVEL 5
func level5_allies():
	return {3:Archer}
	
func level5_enemies():
	var phase = EnemyWrappers.CuratedPhase.new(2)
	phase.add_wave({Vector2(6, 5): make(Grunt, 3), 2: make(Grunt, 3)})
	phase.add_reinforcements({Vector2(2, 3): make(Grunt, 5)})
	var phase2 = EnemyWrappers.CuratedPhase.new(3)
	phase2.add_wave({1: make(Grunt, 5), 3: make(Grunt, 3), 2: make(Grunt, 2), 5: make(Grunt, 6)})
	phase2.add_reinforcements({Vector2(3, 3): make(Grunt, 4), Vector2(2, 3): make(Grunt, 3)})
	phase2.add_reinforcements({Vector2(3, 4): make(Grunt, 3)})
	var phase3 = EnemyWrappers.CuratedPhase.new(1)
	phase3.add_wave({Vector2(1, 5): make(Grunt, 6), Vector2(3, 5): make(Grunt, 6), Vector2(4, 6): make(Grunt, 6),
	Vector2(5, 5): make(Grunt, 4), Vector2(3, 4): make(Grunt, 4)})
	return EnemyWrappers.FinitePhasedWrapper.new([phase, phase2, phase3])
	
func level5_extras():
	var level5_instructions = [
	make_tip("The Archer can attack from range and is able to shoot along diagonal lines.", "Attack diagonally.", Vector2(6, 5), ""),
	make_tip("When the Archer moves, its passive causes it to automatically shoot directly North.", "Use the Archer's passive.", Vector2(2, 7), ""),
	make_tip("A large group of incoming enemies is called a Wave. Check the top of the screen to see when the next Wave appears.", "", null, ""),
	make_tip("When an enemy is summoned onto the board, if the tile is already occupied by a Player Unit, the Player Unit is KOed. If the tile is occupied by an Enemy, it becomes stronger.", "", null, ""),
	make_tip("If a Player Unit is KOed, move another Player Unit adjacent to the tile it was KOed on to revive it. Revived units cannot act on the turn they are revived.", "Clear all enemies before the next Wave appears.", null, "")
	]
	var level5_reinforcements = {3: {0: Berserker, 6: Cavalier}}
	return {"instructions":level5_instructions, "reinforcements":level5_reinforcements, "free_deploy":false}

func level5():
	return LevelTypes.RoomSeal.new(level5_allies(), level5_enemies(), null, level5_extras())

var level5_ref = funcref(self, "level5")

#LEVEL 4
func level4_allies():
	return {3: Berserker, 6: Cavalier}
	
func level4_enemies():
	var phase = EnemyWrappers.CuratedPhase.new(99)
	phase.add_wave({Vector2(2, 3): make(Grunt, 3), 
	Vector2(3, 3): make(Grunt, 5), Vector2(4, 4):make(Grunt, 2),
	Vector2(1, 3): make(Grunt, 2),
	1: make(Grunt, 5), 2: make(Grunt, 3), 3: make(Grunt, 6), 4:make(Grunt, 2)})
	return EnemyWrappers.FinitePhasedWrapper.new([phase])
	
func level4_extras():
	var level4_instructions = [
	make_tip("Each Player Unit can move once per turn. Right Click or press Escape to deselect a Player Unit. To quickly end your turn, press SPACE." \
	,"", null, ""),
	make_tip("If a Player Unit gets a kill, it activates its Combo Ability, which gives a bonus effect to the next Player Unit that acts this turn.", "Activate a Combo.", null, ""),
	make_tip("Press Tab over a Player Unit to see its Combo Ability.", "", null, ""),
	]
	return {"instructions":level4_instructions, "free_deploy":false}

func level4():
	return LevelTypes.RoomSeal.new(level4_allies(), level4_enemies(), level5_ref, level4_extras())

var level4_ref = funcref(self, "level4")


#LEVEL 3
func level3_allies():
	return {Vector2(3, 7): Berserker}
	
	
func level3_enemies():
	var phase = EnemyWrappers.CuratedPhase.new(99)
	phase.add_wave({Vector2(3, 2) : make(Grunt, 2), Vector2(2, 3): make(Grunt, 1), 
	Vector2(3, 3) :make(Grunt, 8), Vector2(3, 5): make(Grunt, 4), 
	Vector2(3, 6): make(Grunt, 6)})
	return EnemyWrappers.FinitePhasedWrapper.new([phase])
	
func level3_extras():
	var level3_instructions = [
	
	make_tip("Enemies will push Player Units forward on their turn. If a Player Unit is pushed off the map, it is KOed.", \
	"Don't let the Berserker get KOed.", Vector2(3, 6), ""),
	make_tip("If a Player Unit is pushed by an Enemy with Health equal to or greater than its Armor, it is also KOed. You LOSE if all Player Units are KOed.", "Don't lose.", null, ""),
	make_tip("Remember that the Berserker stuns enemies with its Passive. If you need a refresher on a Unit, hold Tab over it for a summary.", "" , null, ""),
	]
	return {"instructions":level3_instructions, "free_deploy":false}

func level3():
	return LevelTypes.RoomSeal.new(level3_allies(), level3_enemies(), level4_ref, level3_extras())

var level3_ref = funcref(self, "level3")


#LEVEL 2
func level2_allies():
	return {3: Cavalier}
	
func level2_enemies():
	var phase = EnemyWrappers.CuratedPhase.new(99)
	phase.add_wave({Vector2(3, 6): make(Grunt, 5), Vector2(3, 5): make(Grunt, 5), Vector2(3, 4): make(Grunt, 2)})
	phase.add_reinforcements({1: make(Grunt, 2), 2:make(Grunt, 2)})
	phase.add_reinforcements({3: make(Grunt, 2)})
	return EnemyWrappers.FinitePhasedWrapper.new([phase])

func level2_extras():
	var level2_instructions = [
		make_tip("The Cavalier can run through enemies and Trample them.", \
		"Move the Cavalier behind enemy lines.", Vector2(3, 2), ""),
		make_tip("The Cavalier does 2 damage to each enemy he Tramples through.", \
		"The Cavalier can unleash his direct attack, Charge, when he has an open path to an enemy. Charge at the enemy!", Vector2(3, 6), ""),
		make_tip("Charge deals 1 damage for each tile travelled to the first enemy it hits, and the enemy behind it.", "Eliminate all remaining enemies.", null, ""),
	]
	return {"instructions":level2_instructions, "free_deploy":false}

func level2():
	return LevelTypes.RoomSeal.new(level2_allies(), level2_enemies(), level3_ref, level2_extras())

var level2_ref = funcref(self, "level2")



#LEVEL 1
func level1_allies():
	return {3: Berserker}
	
func level1_enemies():
	var phase = EnemyWrappers.CuratedPhase.new(99)
	phase.add_wave({ Vector2(3, 3): make(Grunt, 7), Vector2(0, 0): make(Grunt, 2)})
	phase.add_reinforcements({0: make(Grunt, 2)})
	phase.add_reinforcements({2: make(Grunt, 2), 3: make(Grunt, 3), 4: make(Grunt, 2)})
	phase.add_reinforcements({4: make(Grunt, 2)})
	return EnemyWrappers.FinitePhasedWrapper.new([phase])

func level1_extras():
	var complex_tooltip1 = [{"coords":Vector2(3, 8), "text":"Click on the Berserker to select it."}, {"coords":Vector2(3, 6), "text": "Click on this tile to move the Berserker here."}]
	var complex_tooltip2 = [{"coords":Vector2(3, 6), "text":"Select the Berserker."}, {"coords":Vector2(3, 4), "text":"Select the enemy to attack it."}]
	var level1_instructions = [
		make_complex_tip("Clear the board of enemies to WIN.", "Move the Berserker towards the enemies.", complex_tooltip1),
		make_complex_tip("Enemies move down one tile each turn. If an enemy moves off the bottom of the map, you LOSE.",  "Attack the nearby enemy.", complex_tooltip2),
		make_tip("The Berserker's direct attack deals 3 damage.",  "Finish off the enemy.", Vector2(3, 5), ""),
		make_tip("When the Berserker kills an enemy, it lands on their tile. ", \
		 "The next group of enemies is outside of direct attack range. Move the Berserker next to them to trigger its passive effect, Ground Slam.", \
		 Vector2(1, 3), ""),
		make_tip("When the Berserker lands on an unoccupied tile, Ground Slam deals 2 damage to adjacent enemies and stuns them, keeping them from moving.", \
		"Finish off the remaining enemies to beat the level.", null, "")
	]
	return {"instructions":level1_instructions, "free_deploy":false}
	
func level1():
	return LevelTypes.RoomSeal.new(level1_allies(), level1_enemies(), level2_ref, level1_extras())

var level1_ref = funcref(self, "level1")





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



