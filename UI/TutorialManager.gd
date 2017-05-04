extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#a dict of dicts
var hero_cooldown_rules = {}

var player_turn_start_rules = {}
var player_turn_end_rules = {}
var enemy_turn_end_rules = {}
var forced_actions = {}

signal rule_finished

var current_rule = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#pops up after a specific hero goes on cooldown
func add_hero_cooldown_rule(rule, turn, hero_name):
	if self.hero_cooldown_rules.has(turn):
		var hero_cooldowns_set = self.hero_cooldown_rules[turn]
		hero_cooldowns_set[hero_name] = rule
	else:
		self.hero_cooldown_rules[turn] = {hero_name: rule}
		
func add_player_turn_end_rule(rule, turn):
	self.player_turn_end_rules[turn] = rule


func add_player_turn_start_rule(rule, turn):
	self.player_turn_start_rules[turn] = rule


func add_enemy_turn_end_rule(rule, turn):
	self.enemy_turn_end_rules[turn] = rule


func add_forced_action(action, turn):
	add_child(action)
	self.forced_actions[turn] = action


func move_is_valid(turn, coords):
	if self.forced_actions.has(turn):
		var forced_action = self.forced_actions[turn]
		return forced_action.move_is_valid(coords)
	return true


func display_forced_action(turn):
	if self.forced_actions.has(turn):
		var forced_action = self.forced_actions[turn]
		var coords = forced_action.get_coords()
		var string = forced_action.get_text()
		update_display_forced_action(coords, string)
	else:
		get_node("Sprite").hide()
		get_node("Label").clear()
		get_node("Arrow").hide()


#called from within the forced action
func update_display_forced_action(coords, text):
	var new_pos = get_parent().get_node("Grid").locations[coords].get_global_pos()
	get_node("Sprite").set_pos(new_pos)
	get_node("Sprite").show()
	
	
	get_node("Label").set_bbcode("[center]" + text + "[/center]")
	if new_pos.y > get_viewport_rect().size.height/2:
		get_node("Label").set_pos(Vector2(0, 300))
	else:
		get_node("Label").set_pos(Vector2(0, get_viewport_rect().size.height  - 300))
	get_node("Label").show()
	
	get_node("Arrow").set_pos(new_pos)
	get_node("Arrow").show()


func finish_forced_action():
	get_node("Sprite").hide()
	get_node("Label").clear()
	get_node("Arrow").hide()


func _input(event):
	if get_node("InputHandler").is_select(event):
		update_rule()
		

func has_player_turn_start_rule(turn):
	return self.player_turn_start_rules.has(turn)
	
func has_player_turn_end_rule(turn):
	return self.player_turn_end_rules.has(turn)

func has_enemy_turn_end_rule(turn):
	return self.enemy_turn_end_rules.has(turn)


func display_player_turn_start_rule(turn):
	set_process_input(true)
	self.current_rule = self.player_turn_start_rules[turn]
	update_rule()

func display_player_turn_end_rule(turn):
	set_process_input(true)
	self.current_rule = self.player_turn_end_rules[turn]
	update_rule()

func display_enemy_turn_end_rule(turn):
	set_process_input(true)
	self.current_rule = self.enemy_turn_end_rules[turn]
	update_rule()
	
func display_hero_cooldown_rule(turn, hero_name):
	set_process_input(true)
	self.current_rule = self.hero_cooldown_rules[turn][hero_name]


func update_rule():
	var line = self.current_rule.get_next_line()
	if line == null:
		self.current_rule = null
		emit_signal("rule_finished")
		get_node("RuleOverlay").hide()
		get_node("Label").clear()
		get_node("TapLabel").hide()
		set_process_input(false)
	else:
		if typeof(line) == TYPE_ARRAY:
			pass
		else:
			get_node("Label").set_pos(Vector2(0, 200))
			get_node("Label").set_bbcode("[center]" + line + "[/center]")
			get_node("TapLabel").show()
			get_node("RuleOverlay").show()

