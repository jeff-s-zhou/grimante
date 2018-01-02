extends Node

var set1 = load("res://LevelSets/Set1.gd").new().get_set()

var set2 = load("res://LevelSets/Set2.gd").new().get_set()

var set3 = load("res://LevelSets/Set3.gd").new().get_set()

var set4 = load("res://LevelSets/Set4.gd").new().get_set()

var set5 = load("res://LevelSets/Set5.gd").new().get_set()

var set6 = load("res://LevelSets/Set6.gd").new().get_set()

var set7 = load("res://LevelSets/Set7.gd").new().get_set()

var set8 = load("res://LevelSets/Set8.gd").new().get_set()

var set9 = load("res://LevelSets/Set9.gd").new().get_set()

var level_sets = [set1, set2, set3, set4, set5, set6, set7, set8, set9]

func get_level_sets():
	return level_sets
