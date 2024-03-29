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
#	
#func add_hint(tutorial, turn, text_list):
#	var hint = RulePrototype.instance()
#	hint.initialize(text_list)
#	tutorial.add_hint(hint, turn)

#identical, I'm just too lazy to fix this shit at this point aaaaa
func add_hint(tutorial, turn, text_list, coords=null):
	var player_start_rule = RulePrototype.instance()
	player_start_rule.initialize(text_list)
	tutorial.add_player_turn_start_rule(player_start_rule, turn, coords)


func add_player_start_rule(tutorial, turn, text_list, coords=null):
	var player_start_rule = RulePrototype.instance()
	player_start_rule.initialize(text_list)
	tutorial.add_player_turn_start_rule(player_start_rule, turn, coords)
	
func add_enemy_start_rule(tutorial, turn, text_list, coords=null):
	var enemy_start_rule = RulePrototype.instance()
	enemy_start_rule.initialize(text_list)
	tutorial.add_enemy_turn_start_rule(enemy_start_rule, turn, coords)
	
func add_enemy_end_rule(tutorial, turn, text_list):
	var enemy_end_rule = RulePrototype.instance()
	enemy_end_rule.initialize(text_list)
	tutorial.add_enemy_turn_end_rule(enemy_end_rule, turn)

func add_forced_action(tutorial, turn, initial_coords, final_coords, result=null, has_arrow=true, text=null):
	var forced_action = ForcedActionPrototype.instance()
	forced_action.initialize(initial_coords, final_coords, result, has_arrow, text)
	tutorial.add_forced_action(forced_action, turn)