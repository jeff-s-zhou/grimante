extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var player_turn_start_rules = {}
var enemy_turn_end_rules = {}
var forced_actions = {} #dict of lists

signal rule_finished

var current_rule = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func add_player_turn_start_rule(rule, turn, coords=null):
	#needed for explaining coords tiles
	if coords != null:
		self.player_turn_start_rules[turn] = {"rule":rule, "coords":coords}
	else:
		self.player_turn_start_rules[turn] = rule


func add_enemy_turn_end_rule(rule, turn):
	self.enemy_turn_end_rules[turn] = rule


func add_forced_action(action, turn):
	add_child(action)
	if self.forced_actions.has(turn):
		self.forced_actions[turn].append(action)
	else:
		self.forced_actions[turn] = [action]


func move_is_valid(turn, coords):
	if self.forced_actions.has(turn) and self.forced_actions[turn] != []:
		var forced_action = self.forced_actions[turn][0]
		var valid = forced_action.move_is_valid(coords, turn)
		if valid:
			var next_state = forced_action.get_next_state()
			if typeof(next_state) == TYPE_ARRAY: #it's the targeted coords and description
				var coords = next_state[0]
				var text = next_state[1]
				update_display_forced_action(coords, text)
			else:
				finish_forced_action(next_state, turn)
				
		return valid
	return true


func display_forced_action(turn):
	if self.forced_actions.has(turn) and self.forced_actions[turn] != []:
		var forced_action = self.forced_actions[turn][0]
		var coords = forced_action.get_coords()
		var string = forced_action.get_text()
		update_display_forced_action(coords, string)
	else:
		get_node("Sprite").hide()
		get_node("Label").hide()
		get_node("Arrow").hide()


#called from within the forced action
func update_display_forced_action(coords, text):
	var new_pos = get_parent().get_node("Grid").locations[coords].get_global_pos()
	get_node("Sprite").set_pos(new_pos)
	get_node("Sprite").show()
	
	get_node("Label").show()
	get_node("Label").set_bbcode("[center]" + text + "[/center]")
	
	if new_pos.y > get_viewport_rect().size.height/2:
		get_node("Label").set_pos(Vector2(24, 300))
	else:
		get_node("Label").set_pos(Vector2(24, get_viewport_rect().size.height  - 300))
		
	
	get_node("Arrow").set_pos(new_pos)
	get_node("Arrow").show()


func finish_forced_action(result_rule, turn):
	#check here if there's another forced action for the turn
	self.forced_actions[turn].pop_front()
	if result_rule != null:
		self.current_rule = result_rule
	
	get_node("Sprite").hide()
	get_node("Label").hide()
	get_node("Arrow").hide()
	

func has_forced_action_result():
	return self.current_rule != null
	

func handle_forced_action_result():
	update_rule()


func _input(event):
	if get_node("InputHandler").is_select(event):
		update_rule(true)
		

func has_player_turn_start_rule(turn):
	return self.player_turn_start_rules.has(turn)


func has_enemy_turn_end_rule(turn):
	return self.enemy_turn_end_rules.has(turn)


func display_player_turn_start_rule(turn):
	self.current_rule = self.player_turn_start_rules[turn]
	update_rule()


func display_enemy_turn_end_rule(turn):
	self.current_rule = self.enemy_turn_end_rules[turn]
	update_rule()


func update_rule(next=false):
	var rule
	var coords
	if typeof(self.current_rule) == TYPE_DICTIONARY:
		coords = self.current_rule.coords
		rule = self.current_rule.rule
	else:
		rule = self.current_rule
		
	var line = rule.get_next_line()
	if line == null:
		self.current_rule = null
		get_node("RuleOverlay").hide()
		get_node("Sprite").hide()
		get_node("Label").hide()
		get_node("TapLabel").hide()
		set_process_input(false)
		emit_signal("rule_finished")
	else:
		if typeof(line) == TYPE_ARRAY: #WTF? Oh this is for when we have images
			pass
		else:
			#next flag is only set when the user clicks to move to the nextl ine
			if !next:
				get_node("Timer").set_wait_time(0.5)
				get_node("Timer").start()
				yield(get_node("Timer"), "timeout")
			
			get_node("Label").set_pos(Vector2(24, 200))
			if line.length() < 35:
				get_node("Label").set_bbcode("[center]" + line + "[/center]")
			else:
				get_node("Label").set_bbcode(line)
			get_node("Label").show()
			get_node("TapLabel").show()
			if coords != null:
				var new_pos = get_parent().get_node("Grid").locations[coords].get_global_pos()
				get_node("Sprite").set_pos(new_pos)
				get_node("Sprite").show()
			else:
				get_node("RuleOverlay").show()
				
			set_process_input(true)

