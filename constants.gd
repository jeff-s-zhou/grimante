extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Fortifier = preload("res://EnemyPieces/FortifierPiece.tscn")
const Grower = preload("res://EnemyPieces/GrowerPiece.tscn")
const Drummer = preload("res://EnemyPieces/DrummerPiece.tscn")
const Melee = preload("res://EnemyPieces/MeleePiece.tscn")
const Ranged = preload("res://EnemyPieces/RangedPiece.tscn")
const Slime = preload("res://EnemyPieces/SlimePiece.tscn")
const Spectre = preload("res://EnemyPieces/SpectrePiece.tscn")
const Dummy = preload("res://EnemyPieces/DummyPiece.tscn")
const Flanker = preload("res://EnemyPieces/FlankerPiece.tscn")
const BossGrunt = preload("res://EnemyPieces/BossGruntPiece.tscn")

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")
const Archer = preload("res://PlayerPieces/ArcherPiece.tscn")
const Cavalier = preload("res://PlayerPieces/CavalierPiece.tscn")
const Assassin = preload("res://PlayerPieces/AssassinPiece.tscn")
const FrostKnight = preload("res://PlayerPieces/FrostKnightPiece.tscn")
const Corsair = preload("res://PlayerPieces/CorsairPiece.tscn")
const Stormdancer = preload("res://PlayerPieces/StormdancerPiece.tscn")
const Pyromancer = preload("res://PlayerPieces/PyromancerPiece.tscn")
const Saint = preload("res://PlayerPieces/SaintPiece.tscn")

var end_conditions = {"Defend":0, "Escort":1, "Timed":2, "Sandbox":3}


var enemy_modifiers = {"Poisonous":"Poisonous", "Shield":"Shield", "Cloaked":"Cloaked", "Corrosive":"Corrosive", "Predator":"Predator"}

#used in the level editor
var enemy_roster = {"dummy":Dummy, "grunt":Grunt, "fortifier":Fortifier, "grower":Grower, "drummer":Drummer, 
"melee":Melee, "ranged":Ranged, "slime":Slime, "spectre":Spectre, "flanker":Flanker, "boss_grunt":BossGrunt}

var hero_roster = {"berserker":Berserker, "cavalier":Cavalier, "archer":Archer, "assassin":Assassin, "frost_knight":FrostKnight,
"corsair":Corsair, "stormdancer":Stormdancer, "pyromancer":Pyromancer, "saint":Saint}

const y_coords_offsets = [0, 0, 1, 1, 2, 2, 3]


const coords_vertical_prob_dist = {
0: 1,
1: 1,
2: 1,
3: 0.7,
4: 0.4
}

const coords_horizontal_prob_dist = {
0: 1,
1: 1,
2: 1,
3: 1,
4: 1,
5: 1,
6: 1
}

var UNIT_POWER_LEVELS = {
Grunt: 30,
Fortifier: 35,
Grower: 35,
Drummer: 40,
Spectre: 40,
Slime: 40,
Melee: 50,
Ranged: 50,
}

#potential problem, we don't want Fortifiers with shield_modifiers do we?
var MODIFIER_POWER_LEVELS = {
enemy_modifiers["Shield"]: 14,
enemy_modifiers["Poisonous"]: 18,
enemy_modifiers["Cloaked"] : 10,
enemy_modifiers["Corrosive"] : 10,
enemy_modifiers["Predator"] : 10
}

#used in the generator
var FULL_UNIT_ROSTER = {
0: Grunt,
1: Fortifier,
2: Grower,
3: Drummer,
4: Melee,
5: Ranged,
6: Slime,
7: Spectre,
8: Dummy,
9: Flanker,
10: BossGrunt
}

#used in the generator
var FULL_MODIFIER_ROSTER = {
0: enemy_modifiers["Shield"],
1: enemy_modifiers["Poisonous"],
2: enemy_modifiers["Cloaked"],
3: enemy_modifiers["Corrosive"],
4: enemy_modifiers["Predator"]
}

const GRUNT_HEALTH_PROB_DIST = {
1: 0.3,
2: 0.7,
3: 1,
4: 1,
5: 1,
6: 0.5,
7: 0.3,
8: 0.1,
9: 0.1,
}

const GRUNT_PLACEMENT_PROB_DIST = {
0: 1,
1: 1,
2: 1,
3: 1,
4: 1,
5: 1,
6: 1
}

const FORTIFIER_HEALTH_PROB_DIST = {
1: 0.3,
2: 1,
3: 1,
4: 0.8,
5: 0.3,
6: 0.2
}

const FORTIFIER_PLACEMENT_PROB_DIST = {
0: 0.5,
1: 1,
2: 1,
3: 1,
4: 1,
5: 1,
6: 0.5
}

const GROWER_HEALTH_PROB_DIST = {
1: 0.8,
2: 1,
3: 0.8,
4: 0.5,
5: 0.3
}

const GROWER_PLACEMENT_PROB_DIST = {
0: 1,
1: 0.7,
2: 0.7,
3: 0.7,
4: 0.7,
5: 0.7,
6: 1
}

const DRUMMER_HEALTH_PROB_DIST = {
1: 0.5,
2: 0.8,
3: 1,
4: 0.8,
5: 0.5,
6: 0.2
}


const SPECTRE_HEALTH_PROB_DIST = {
3: 1,
4: 1,
5: 1,
6: 0.7,
7: 0.6,
8: 0.5,
9: 0.3
}

const MELEE_HEALTH_PROB_DIST = {
3: 1,
4: 1,
5: 1,
6: 0.7,
7: 0.6,
8: 0.5,
9: 0.3
}

const RANGED_HEALTH_PROB_DIST = {
3: 1,
4: 1,
5: 0.8,
6: 0.6,
7: 0.5,
8: 0.3,
}

const SLIME_HEALTH_PROB_DIST = {
3: 1,
4: 1,
5: 1,
6: 0.7,
7: 0.6,
8: 0.5,
9: 0.3
}
