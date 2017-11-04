extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
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


class Set:
	var id = null
	var name = ""
	var levels = []
	var hard_levels = []
	
	func _init(id, name, levels, hard_levels):
		self.id = id
		self.name = name
		self.levels = levels
		self.hard_levels = hard_levels
		
	func get_levels():
		for i in range(0, self.levels.size() - 1):
			#change this call to set_next_level
			self.levels[i].set_next_level(self.levels[i+1])
		return self.levels
		
	func get_hard_levels():
		for i in range(0, self.hard_levels.size() - 1):
			#change this call to set_next_level
			self.hard_levels[i].set_next_level(self.hard_levels[i+1])
		return self.hard_levels
		
		
func sandbox(): 
	var flags = []
	var score_guide = {0:2, 1:4}
	var extras1 = {"free_deploy":true, "flags":flags, "score_guide":score_guide}
	var raw_enemies = {0:{Vector2(2, 5): make(Grunt, 2)}}
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var heroes = {0: Cavalier, 2: Berserker, 4:Assassin, 5: FrostKnight} 
	return LevelTypes.Timed.new(33333, "", heroes, enemies, 2, null, extras1) 
#	
#func background():
#	var pieces = load_level("background.level")
#	var raw_enemies = pieces[0]
#	var allies = pieces[1]
#	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
#	var flags = []
#	var extras = {"flags":flags, "free_deploy":false}
#	return LevelTypes.Timed.new("Big Boss Fight", allies, enemies, 5, null, extras)