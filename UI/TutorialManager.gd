extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var player_turn_start_rules = {}
var enemy_turn_end_rules = {}
var forced_actions = {} #dict of lists

signal rule_finished

var current_rule = null

var continue_text = "Click anywhere to continue [%s/%s]"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	

func decorate(string):
	string = string.replace("{", "[color=#ff3333]")
	string = string.replace("}", "[/color]")
	return string


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
		

func has_forced_action(turn):
	return self.forced_actions.has(turn) and self.forced_actions[turn] != []


func display_forced_action(turn):
	var forced_action = self.forced_actions[turn][0]
	var initial_coords = forced_action.get_initial_coords()
	var target_coords = forced_action.get_final_coords()
	
	var initial_pos = get_parent().get_node("Grid").locations[initial_coords].get_global_pos()
	var target_pos = get_parent().get_node("Grid").locations[target_coords].get_global_pos()
	get_parent().get_node("Grid").focus_coords(initial_coords, target_coords)
	
	#so the text is more readable
	if forced_action.has_text():
		get_node("Sprite").set_opacity(0.8)
	get_node("Sprite").set_pos(initial_pos)
	get_node("Sprite").show()
	get_node("Light2D").set_pos(target_pos)
	get_node("Light2D").show()
	
	if forced_action.has_arrow():
		get_node("Arrow").set_pos(initial_pos)
		get_node("Arrow").show()


func move_is_valid(turn, coords):
	if self.forced_actions.has(turn) and self.forced_actions[turn] != []:
		var forced_action = self.forced_actions[turn][0]
		var valid = forced_action.move_is_valid(coords, turn)
		if valid:
			forced_action.update()
			if forced_action.is_finished():
				get_parent().get_node("Grid").unfocus()
				get_node("Sprite").hide()
				get_node("Light2D").hide()
				get_node("Arrow").hide()
				get_node("Label").hide()
				get_node("Sprite").set_opacity(0.6)
				
				self.current_rule = self.forced_actions[turn][0].result_rule
				self.forced_actions[turn].pop_front()
				
			#only need to update anything on screen if we're displaying visible arrows
			elif forced_action.has_arrow():
				if forced_action.has_text():
					get_node("Label").set_bbcode(decorate(forced_action.text))
					get_node("Label").show()
				
				var target_coords = forced_action.get_final_coords()
				var target_pos = get_parent().get_node("Grid").locations[target_coords].get_global_pos()
				get_node("Arrow").set_pos(target_pos)
				get_node("Arrow").show()
		return valid
	return true

func has_forced_action_result(turn):
	return self.forced_actions.has(turn) and self.forced_actions[turn] != [] and self.forced_actions[turn][0].has_result()

func handle_forced_action_result(turn):
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
		get_node("Sprite").set_opacity(0.6)
		get_node("Sprite").hide()
		get_node("Light2D").hide()
		get_node("Label").hide()
		get_node("TapLabel").hide()
		set_process_input(false)
		emit_signal("rule_finished")
	else:
		if typeof(line) == TYPE_ARRAY: #WTF? Oh this is for when we have images
			pass
		else:
			line = decorate(line)
			#next flag is only set when the user clicks to move to the nextl ine
			if !next:
				get_node("Timer").set_wait_time(0.5)
				get_node("Timer").start()
				yield(get_node("Timer"), "timeout")
			
			get_node("Label").set_pos(Vector2(24, 200))
			if line.length() < 35:
				get_node("Label").set_bbcode("[center]" + line + "[/center]")
				get_node("TapLabel").set_align(HALIGN_CENTER)
			else:
				get_node("Label").set_bbcode(line)
				get_node("TapLabel").set_align(HALIGN_LEFT)
			
			get_node("Label").show()
			
			var filled_cont_text = continue_text % [rule.get_index(), rule.get_size()]
			get_node("TapLabel").set_text(filled_cont_text)
			get_node("TapLabel").show()
			if coords != null:
				var new_pos = get_parent().get_node("Grid").locations[coords].get_global_pos()
				get_node("Sprite").set_opacity(0.8)
				get_node("Sprite").set_pos(new_pos)
				get_node("Sprite").show()
			else:
				get_node("RuleOverlay").show()
				
			set_process_input(true)

