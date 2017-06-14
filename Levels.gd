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
	#var enemies = {0:{ Vector2(3, 5): make(Grunt, 4)}}
	var enemies = load_level("frost_knight.level")
	return EnemyWrappers.FiniteCuratedWrapper.new(enemies)
	
func sandbox_extras():
	#return {"shifting_sands_tiles": {Vector2(3, 6): 4}, "tutorial":tutorial}
	return {"required_units":{3: FrostKnight, 4: Assassin}}

func sandbox():  
	return LevelTypes.Timed.new("Test Name", sandbox_allies(), sandbox_enemies(), 3, null, sandbox_extras()) 

var list = [sandbox()]

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
	
	var fa_text1 = "The Cavalier has arrived! Let's see what it can do."
	var fa_text2 = "The Cavalier can move any number of tiles in all six directions."
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(0, 4), fa_text2)
	
	
	var text = ["The Cavalier can run through enemies with its Indirect Attack: Trample.", \
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
	
	var fa_text1 = "The Archer is here!"
	var fa_text2 = "The Archer can Direct Attack from a distance by firing a Piercing Arrow."
	var text = ["The Piercing Arrow hits the first target along a line for 3 damage."]
	
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 4), fa_text2, text)
	
	fa_text1 = "The Archer's Piercing Arrow has a special effect when it kills an enemy."
	text = ["If the Archer's Piercing Arrow kills, it continues to travel.", 
	"The arrow deals 1 less damage to each successive enemy until it fails to kill, or its damage reaches 0."]
	
	add_forced_action(tutorial, 2, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text1, text)
	
	#it's after here it stops detecting the FAR?
	
	fa_text1 = "The Archer can shoot along \"hex diagonal\" angles to hit tricky targets."
	text = ["test result"]
	add_forced_action(tutorial, 3, Vector2(3, 7), fa_text1, Vector2(1, 3), fa_text1, text)
	
	fa_text1 = "The Archer doesn't just have to sit still."
	text = ["When the Archer moves, its passive causes it to automatically fire a Piercing Arrow directly north."]
	add_forced_action(tutorial, 4, Vector2(3, 7), fa_text1, Vector2(4, 7), fa_text1, text)
	
	
	text = ["The Archer's shots are blocked by other Heroes.", 
	"Can you clear the board this turn?"]
	add_player_start_rule(tutorial, 5, text)
	
	
	return tutorial


func archer():
	var allies = []
	var raw_enemies = load_level("archer.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var reinforcements = {5: { Vector2(5, 7): Berserker}}
	var flags = ["no_stars", "no_turns", "no_inspire"]
	var tutorial_func = funcref(self, "archer_tutorial")
	var extras = {"free_deploy":false, "reinforcements":reinforcements, "required_units":{3:Archer}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Archer", allies, enemies, 7, null, extras)


func offsides_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var text = ["A Piece cannot be pushed if there's another Piece behind it."]
	add_player_start_rule(tutorial, 1, text)
	
	var fa_text1 = "Block the Enemies."
	
	add_forced_action(tutorial, 1, Vector2(4, 7), fa_text1, Vector2(3, 7), fa_text1)
	
	add_forced_action(tutorial, 1, Vector2(2, 6), fa_text1, Vector2(3, 6), fa_text1)
	
	text = ["The Archer behind the Cavalier blocks the Enemy from advancing.", 
	"Be careful however, as powerful enemies can still KO weaker Heroes."]
	add_enemy_end_rule(tutorial, 1, text)
	
	text = ["Enemies cannot reinforce past the furthest back Player Unit."]
	add_player_start_rule(tutorial, 2, text)
	
	fa_text1 = "Move your units forward."
	
	add_forced_action(tutorial, 2, Vector2(3, 6), fa_text1, Vector2(3, 1), fa_text1)
	
	add_forced_action(tutorial, 2, Vector2(3, 7), fa_text1, Vector2(3, 6), fa_text1)
	
	text = ["Look to move your Heroes forward in order to reduce the area in which Enemies can reinforce."]
	add_enemy_end_rule(tutorial, 2, text)
	
	return tutorial

func offsides():
	var allies = []
	var raw_enemies = load_level("offsides.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_turns", "no_inspire"]
	var tutorial_func = funcref(self, "offsides_tutorial")
	var extras = {"free_deploy":false, "required_units":{2:Cavalier, 4: Archer}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Offsides!", allies, enemies, 7, null, extras)
	
func tick_tock_tutorial():
	var tutorial = TutorialPrototype.instance()
	var text = ["Clear the board within the turn limit displayed at the top of the screen, or else you lose!"]
	add_player_start_rule(tutorial, 1, text)
	
	var text = ["Special enemies with abilities have appeared!", "Press Tab over them to read what their abilities do."]
	add_enemy_end_rule(tutorial, 1, text)
	
	var text = ["Don't forget to move past Enemy reinforcements to cancel them!"]
	add_player_start_rule(tutorial, 3, text)
	return tutorial
	
func tick_tock():
	var allies = []
	var raw_enemies = load_level("tick_tock.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var tutorial_func = funcref(self, "tick_tock_tutorial")
	var extras = {"free_deploy":false, "required_units":{2:Cavalier, 3:Berserker, 4: Archer}, "tutorial": tutorial_func, "flags":flags}
	
	return LevelTypes.Timed.new("Tick Tock", allies, enemies, 7, null, extras)
	
func flying_solo():
	var allies = []
	var raw_enemies = load_level("flying_solo.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars", "no_inspire"]
	var extras = {"free_deploy":false, "required_units":{2:Cavalier, 3:Berserker, 4: Archer}, "flags":flags}
	return LevelTypes.Timed.new("Flying Solo", allies, enemies, 7, null, extras)
	

func assassin_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var fa_text1 = "The Assassin is now at your disposal."
	var fa_text2 = "The Assassin attacks by Backstabbing."
	var text = ["The Assassin's Backstab teleports it behind the target and deals 2 damage."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text2, text)
	
	fa_text1 = "The Assassin activates a unique ability when it kills an Enemy."
	text = ["After killing an Enemy, the Assassin can act again.", 
	"This can only occur once per turn."]
	
	add_forced_action(tutorial, 2, Vector2(3, 4), fa_text1, Vector2(3, 6), fa_text1, text)
	
	fa_text1 = ""
	text = ["If an Enemy has no other Enemies adjacent to it, Backstab deals 4 damage."]
	add_forced_action(tutorial, 2, Vector2(3, 5), fa_text1, Vector2(2, 5), fa_text1, text)
	
	fa_text1 = "Let's prepare the Assassin's Indirect Attack."
	fa_text2 = "Move the Assassin next to this enemy."
	add_forced_action(tutorial, 3, Vector2(2, 4), fa_text1, Vector2(4, 4), fa_text2) 
	
	text = ["If an Enemy adjacent to the Assassin is attacked and isn't killed, the Assassin automatically attacks it for 1 damage.",
	"Furthermore, if the Assassin is on cooldown, its Indirect Attack also lets it act again!"]
	fa_text1 = "Now we send the Cavalier to act."
	fa_text2 = ""
	add_forced_action(tutorial, 3, Vector2(5, 8), fa_text1, Vector2(5, 4), fa_text2, text) 
	
	add_forced_action(tutorial, 3, Vector2(4, 4), "", Vector2(3, 2), "")
	
	text = ["Can you clear the board this turn?"]
	add_player_start_rule(tutorial, 4, text)

	return tutorial
	
func assassin():
	var allies = []
	var raw_enemies = load_level("assassin.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "assassin_tutorial")
	var flags = ["no_stars", "no_inspire"]
	var reinforcements = {3: {5:Cavalier}}
	var extras = {"free_deploy":false, "required_units":{3:Assassin}, "flags":flags, "tutorial":tutorial_func, "reinforcements":reinforcements}
	return LevelTypes.Timed.new("Assassin", allies, enemies, 7, null, extras)
	

func deploy_tutorial():
	var tutorial = TutorialPrototype.instance()
	var text = ["This is the deployment phase.", 
	"Here, you choose which Heroes to use and can rearrange your Heroes before the level starts.",
	"Press DEPLOY when finished."]
	add_player_start_rule(tutorial, 0, text)
	return tutorial
	
func deploy():
	var allies = []
	var raw_enemies = load_level("deploy.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "deploy_tutorial")
	var flags = ["no_stars", "no_inspire"]
	var extras = {"required_units":{2: Cavalier, 3:Archer, 4:Assassin, Vector2(3, 6): Berserker}, "flags":flags, "tutorial":tutorial_func}
	return LevelTypes.Timed.new("Deploy", allies, enemies, 7, null, extras)
	

func mutation_tutorial():
	var tutorial = TutorialPrototype.instance()
	var text = ["Enemies can have mutations, which give them additional special effects.", 
	"Press Tab over an enemy with a mutation to learn about it."]
	add_player_start_rule(tutorial, 0, text, Vector2(2, 5))
	return tutorial
	
	
func mutation():
	var allies = []
	var raw_enemies = load_level("mutation.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "mutation_tutorial")
	var flags = ["no_stars", "no_inspire"]
	var extras = {"required_units":{2: Cavalier, 3:Archer, 4:Assassin, Vector2(3, 6): Berserker}, "flags":flags, "tutorial":tutorial_func}
	return LevelTypes.Timed.new("Mutation", allies, enemies, 7, null, extras)
	
func rising_tides_tutorial():
	var tutorial = TutorialPrototype.instance()
	var text = ["Remember that moving past enemy reinforcements will prevent them from appearing!"]
	add_player_start_rule(tutorial, 1, text)
	return tutorial

#might be too hard
func rising_tides():
	var allies = []
	var raw_enemies = load_level("rising_tides.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "rising_tides_tutorial")
	var flags = ["no_stars", "no_inspire"]
	var extras = {"required_units":{2: Cavalier, 3:Archer, 4:Assassin, Vector2(3, 6): Berserker}, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Rising Tides", allies, enemies, 7, null, extras)
	
func inspire_tutorial():
	var tutorial = TutorialPrototype.instance()
	var text = ["Heroes can now Inspire other Heroes.", 
	"After killing an Enemy, a Hero gives a bonus effect to the next Hero that acts."]
	add_player_start_rule(tutorial, 1, text)
	
	var fa_text1 = "Let's kill these enemies with the Berserker."
	text = ["The Berserker inspires allies to Attack.", 
	"Whenever it kills an enemy, the next Hero that acts receives +1 to all damage dealt."]
	add_forced_action(tutorial, 1, Vector2(1, 6), fa_text1, Vector2(1, 4), fa_text1, text)
	
	fa_text1 = "Now the Cavalier can do some big damage!"
	add_forced_action(tutorial, 1, Vector2(5, 8), fa_text1, Vector2(5, 3), fa_text1)
	
	fa_text1 = "Now let's have the Cavalier Inspire the Berserker."
	text = ["The Cavalier inspires allies to Move.",  
	"Whenever it kills an enemy, the next Hero gains an additional 1 range to its movement."]
	add_forced_action(tutorial, 2, Vector2(5, 3), fa_text1, Vector2(0, 3), fa_text1, text)
	
	text = ["The Assassin inspires Attack, and the Archer inspires Movement.",
	"Press Tab over a Hero to see what it Inspires."]
	
	add_player_start_rule(tutorial, 3, text)

	return tutorial
	
func inspire():
	var allies = []
	var raw_enemies = load_level("inspire.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "inspire_tutorial")
	var flags = ["no_stars"]
	var reinforcements = {3: {2: Archer, 3: Assassin}}
	var extras = {"free_deploy":false, "required_units":{1: Berserker, 5: Cavalier}, "tutorial": tutorial_func, "reinforcements":reinforcements, "flags":flags}
	return LevelTypes.Timed.new("Power of Friendship", allies, enemies, 7, null, extras)
	
	
func swamp():
	var allies = []
	var raw_enemies = load_level("swamp.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars"]
	var extras = {"required_units":{2: Cavalier, 3:Archer, 4:Assassin, Vector2(3, 6): Berserker}, "flags":flags}
	return LevelTypes.Timed.new("Dagobah", allies, enemies, 7, null, extras)

	
func stormdancer_tutorial():
	var tutorial = TutorialPrototype.instance()

	var fa_text1 = "The Stormdancer is here to help!"
	var fa_text2 = "Let's move the Stormdancer forward."
	var text = ["The Stormdancer leaves behind a Storm tile whenever it moves.", 
	"The Storm tile stays on the board for the rest of the level."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(4, 6), fa_text2, text)
	
	var text =["If an Enemy steps on a Storm Tile, it takes 2 damage."]
	add_enemy_end_rule(tutorial, 1, text)
	
	fa_text1 = "Let's use the Stormdancer's Direct Attack!"
	text = ["The Stormdancer has the ability to swap positions with Enemies or Heroes within its movement range."]
	add_forced_action(tutorial, 2, Vector2(4, 6), fa_text1, Vector2(3, 4), fa_text1, text)
	
	text = ["The Stormdancer inspires Heroes to Defend."]
	add_player_start_rule(tutorial, 3, text)
	
	fa_text1 = ""
	text = ["Unlike other Inspires, Defense is always triggered whenever the Stormdancer takes action."]
	add_forced_action(tutorial, 3, Vector2(3, 4), fa_text1, Vector2(3, 2), fa_text1, text)
	
	text = ["Defense stays on a Hero until its next turn."]
	add_forced_action(tutorial, 3, Vector2(3, 7), fa_text1, Vector2(3, 4), fa_text1, text)
	
	text = ["When Heroes Defend, they cannot be KOed by any means or shoved."]
	add_enemy_end_rule(tutorial, 3, text)
	
	text = ["Clear the level before the start of your next turn!",  
	"Hint: Remember that the Stormdancer's Swap doesn't just affect enemies."]
	add_player_start_rule(tutorial, 4, text)
	
	return tutorial
	
func stormdancer():
	var allies = []
	var raw_enemies = load_level("stormdancer.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "stormdancer_tutorial")
	var flags = ["no_stars"]
	var reinforcements = {3: {3: Cavalier}, 4: {Vector2(1, 2): Berserker}}
	var extras = {"free_deploy":false, "required_units":{3: Stormdancer}, "tutorial": tutorial_func, "reinforcements":reinforcements, "flags":flags}
	return LevelTypes.Timed.new("Stormdancer", allies, enemies, 4, null, extras)


func double_time_tutorial():
	var tutorial = TutorialPrototype.instance()
	var text = ["This is an Elite Enemy.", 
	"Elite Enemies have powerful effects, so think carefully about how to handle them!"]
	add_player_start_rule(tutorial, 0, text, Vector2(3, 3))
	return tutorial

func double_time():
	var allies = []
	var raw_enemies = load_level("double_time.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars"]
	var tutorial_func = funcref(self, "double_time_tutorial")
	var extras = {"required_units":{1: Stormdancer, 2: Cavalier, 3:Berserker, 4:Assassin, 5: Archer}, "tutorial":tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Double Time", allies, enemies, 7, null, extras)
	

func defuse_the_bomb():
	var allies = []
	var raw_enemies = load_level("defuse_the_bomb.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars"]
	var extras = {"required_units":{1: Stormdancer, 2: Cavalier, 3:Berserker, 4:Assassin, 5: Archer}, "flags":flags}
	return LevelTypes.Timed.new("Defuse the Bomb", allies, enemies, 3, null, extras)

func spoopy_ghosts():
	var allies = []
	var raw_enemies = load_level("spoopy_ghosts.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var flags = ["no_stars"]
	var extras = {"required_units":{1: Stormdancer, 2: Cavalier, 3:Berserker, 4:Assassin, 5: Archer}, "flags":flags}
	return LevelTypes.Timed.new("Spoopy Ghosts", allies, enemies, 7, null, extras)
	
func pyromancer_tutorial():
	var tutorial = TutorialPrototype.instance()
	
	var fa_text1 = "The Pyromancer is going to set the world in flames, and no one can stop him!"
	var fa_text2 = "Let's move the Pyromancer forward and use its Indirect Attack."
	var text = ["Whenever the Pyromancer moves, it tosses a Firebomb in the direction it moves!", 
	"Enemies hit take 2 damage, and are inflicted with Burn."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(2, 6), fa_text2, text)
	
	text = ["Burned Enemies take 1 damage a turn."]
	add_enemy_end_rule(tutorial, 1, text)
	
	fa_text1 = "The Pyromancer can only move forward." 
	fa_text2 = "In addition, the Pyromancer can only attack by moving!"
	text = [" Fire will spread to a single adjacent enemy at random, and will chain up to 4 times."]
	add_forced_action(tutorial, 2, Vector2(2, 6), fa_text1, Vector2(2, 5), fa_text2, text)
	return tutorial
	
func pyromancer():
	var allies = []
	var raw_enemies = load_level("pyromancer.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "pyromancer_tutorial")
	var flags = ["no_stars"]
	var extras = {"free_deploy":false, "required_units":{3: Pyromancer}, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Stormdancer", allies, enemies, 4, null, extras)


func corsair_tutorial():
	var tutorial = TutorialPrototype.instance()
	var fa_text1 = "The Corsair is ready to buckle some swashes."
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text1)
	fa_text1 = "The Corsair can act twice each turn without any conditions."
	add_forced_action(tutorial, 1, Vector2(3, 5), fa_text1, Vector2(3, 3), fa_text1)
	
	var text = ["The Corsair can act twice a turn, but he cannot attack while moving."]
	add_player_start_rule(tutorial, 2, text)
	
	fa_text1 = "Move the Corsair adjacent to an enemy to then attack it."
	add_forced_action(tutorial, 2, Vector2(3, 3), fa_text1, Vector2(1, 2), fa_text1)
	add_forced_action(tutorial, 2, Vector2(1, 2), "", Vector2(0, 1), "")
	
	fa_text1 = "The Corsair has one more trick up its sleeve."
	text = [" The Corsair can use its hook to drag enemies close from 2 distance away in a straight line.",
	"It then automatically attacks the enemy."]
	add_forced_action(tutorial, 3, Vector2(1, 2), fa_text1, Vector2(3, 3), fa_text1)
	add_forced_action(tutorial, 3, Vector2(3, 3), fa_text1, Vector2(5, 3), fa_text1, text)
	
	fa_text1 = "The Corsair can also hook allies!"
	text = ["Clear this tutorial before time runs out!", 
	"Hint: The Corsair inspires Movement."]
	add_forced_action(tutorial, 4, Vector2(3, 3), fa_text1, Vector2(3, 5), fa_text1, text)
	return tutorial

func corsair():
	var allies = []
	var raw_enemies = load_level("corsair.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "corsair_tutorial")
	var flags = ["no_stars"]
	var reinforcements = {4: {Vector2(3, 5): Berserker, Vector2(2, 6): Archer}}
	var extras = {"free_deploy":false, "required_units":{3: Corsair}, "reinforcements":reinforcements, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Corsair", allies, enemies, 4, null, extras)
	
func frost_knight_tutorial():
	var tutorial = TutorialPrototype.instance()
	var fa_text1 = "The Frost Knight is at your command."
	var text = ["The Frost Knight can shove Enemies and Heroes.", 
	"Shoved Enemies are Frozen and Stunned."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 6), fa_text1, text)
	
	fa_text1 = "Let's attack the Frozen Enemy and see what happens."
	text = ["Frozen units, if killed, shatter and deal 2 damage to all adjacent Enemies.",  
	"NOTE: Being Burned by the Pyromancer cancels out being Frozen, and vice versa."]
	add_forced_action(tutorial, 1, Vector2(2, 6), fa_text1, Vector2(3, 5), fa_text1, text)
	
	add_forced_action(tutorial, 2, Vector2(2, 6), "", Vector2(2, 5), "")
	
	fa_text1 = "The Frost Knight can only move in the 6 hexagonal directions, even when Inspired."
	add_forced_action(tutorial, 2, Vector2(3, 6), fa_text1, Vector2(5, 6), fa_text1)
	
	text = ["Enemies shoved off the map on any side except the bottom are KOed."]
	add_forced_action(tutorial, 2, Vector2(5, 6), "", Vector2(6, 6), "", text)
	

	
	
	
	return tutorial
	
func frost_knight():
	var allies = []
	var raw_enemies = load_level("frost_knight.level")
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var tutorial_func = funcref(self, "frost_knight_tutorial")
	var flags = ["no_stars"]
	var extras = {"free_deploy":false, "required_units":{2: Archer, 3: FrostKnight}, "tutorial": tutorial_func, "flags":flags}
	return LevelTypes.Timed.new("Frost Knight", allies, enemies, 4, null, extras)


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
