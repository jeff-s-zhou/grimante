extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const Grunt = preload("res://EnemyPieces/GruntPiece.tscn")
const Fortifier = preload("res://EnemyPieces/FortifierPiece.tscn")
const Grower = preload("res://EnemyPieces/GrowerPiece.tscn")
const Drummer = preload("res://EnemyPieces/DrummerPiece.tscn")

var enemy_modifiers = {"Poisonous":"Poisonous", "Shield":"Shield"}

var UNIT_POWER_LEVELS = {
Grunt: 20,
Fortifier: 35,
Grower: 35,
Drummer: 45
}

#potential problem, we don't want Fortifiers with shield_modifiers do we?
var MODIFIER_POWER_LEVELS = {
enemy_modifiers["Shield"]: 10,
enemy_modifiers["Poisonous"]: 20
}


var FULL_UNIT_ROSTER = {
0: Grunt,
1: Fortifier,
2: Grower,
3: Drummer
}

var FULL_MODIFIER_ROSTER = {
0: enemy_modifiers["Shield"],
1: enemy_modifiers["Poisonous"],
}

const GRUNT_HEALTH_PROB_DIST = {
1: 0.3,
2: 1,
3: 1,
4: 1,
5: 0.5,
6: 0.4,
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
4: 0.5,
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
1: 1,
2: 1,
3: 0.5,
4: 0.3,
5: 0.2
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
1: 1,
2: 1,
3: 1,
4: 0.8,
5: 0.6,
6: 0.2
}