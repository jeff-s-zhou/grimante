extends Node

var ForcedActionPrototype = load("res://UI/ForcedAction.tscn")
var RulePrototype = load("res://UI/TutorialRule.tscn")
var TutorialPrototype = load("res://UI/TutorialManager.tscn")

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

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