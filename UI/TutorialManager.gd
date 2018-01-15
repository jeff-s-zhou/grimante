extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var player_turn_start_rules = {}
var enemy_turn_end_rules = {}
var enemy_turn_start_rules = {}
var forced_actions = {} #dict of lists

var hints = {}

signal rule_finished

var current_rule = null

var resolution

var continue_text = "Click anywhere to continue (%s/%s)"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	var material = get_node("Text").get_material()
	#material.set("shader_param/strength", 1.5)
#	var screen_size = get_viewport().get_rect().size
#	var halfway = screen_size/2
#	get_node("Text/Label").set_global_pos(halfway - (get_node("Text/Label").get_size()/2) + Vector2(0, -100))
#	get_node("Text/TapText/Label").set_global_pos(halfway - (get_node("Text/TapText/Label").get_size()/2) + Vector2(0, 100))
#

func _enter_tree():
#	._enter_tree()
	self.resolution = get_node("/root/global").get_resolution()
	get_node("Text").set_global_pos(resolution/2)

func decorate(string):
	string = string.replace("{", "[color=#ff3333]")
	string = string.replace("}", "[/color]")
	return string
	
	
func add_hint(rule, turn):
	self.hints[turn] = rule


func add_player_turn_start_rule(rule, turn, coords=null):
	#needed for explaining coords tiles
	if coords != null:
		self.player_turn_start_rules[turn] = {"rule":rule, "coords":coords}
	else:
		self.player_turn_start_rules[turn] = rule


func add_enemy_turn_end_rule(rule, turn):
	self.enemy_turn_end_rules[turn] = rule
	
func add_enemy_turn_start_rule(rule, turn, coords=null):
	if coords != null:
		self.enemy_turn_start_rules[turn] = {"rule":rule, "coords":coords}
	else:
		self.enemy_turn_start_rules[turn] = rule

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
	
	#so the text is more readable
	if forced_action.has_text():
		get_node("Sprite").set_opacity(0.8)
	else:
		get_node("Sprite").set_opacity(0.6)
	get_node("Sprite").set_pos(initial_pos)
	get_node("Sprite").show()
	get_node("Light2D").set_pos(target_pos)
	get_node("Light2D").show()
	
	if forced_action.has_arrow():
		get_node("Arrow").set_pos(initial_pos)
		get_node("Arrow").show()
		
		
	get_parent().get_node("Grid").focus_coords(initial_coords, target_coords)
	get_node("AnimationPlayer 2").play("fade_in")
	yield(get_node("AnimationPlayer 2"), "finished")


func move_is_valid(turn, coords):
	if self.forced_actions.has(turn) and self.forced_actions[turn] != []:
		var forced_action = self.forced_actions[turn][0]
		var valid = forced_action.move_is_valid(coords, turn)
		if valid:
			forced_action.update()
			if forced_action.is_finished():
				get_parent().get_node("Grid").unfocus()
				get_node("AnimationPlayer 2").play("fade_out")
				yield(get_node("AnimationPlayer 2"), "finished")
				get_node("Sprite").hide()
				get_node("Light2D").hide()
				get_node("Arrow").hide()
				get_node("Text").hide()
				get_node("Sprite").set_opacity(0.6)
				
				if self.forced_actions[turn][0].has_result():
					self.current_rule = self.forced_actions[turn][0].result_rule
				self.forced_actions[turn].pop_front()
				
			#only need to update anything on screen if we're displaying visible arrows
			elif forced_action.has_arrow():
				var target_coords = forced_action.get_final_coords()
				var target_pos = get_parent().get_node("Grid").locations[target_coords].get_global_pos()
				get_node("Arrow").set_pos(target_pos)
				get_node("Arrow").show()
				
				if forced_action.has_text():
#					if target_pos.y > (self.resolution/2).y:
					get_node("Text").set_global_pos(self.resolution/2 + Vector2(0, -225))
#					else:
#						get_node("Text").set_global_pos(self.resolution/2 + Vector2(0, 200))
					get_node("Text/Label").set_bbcode(decorate(forced_action.text))
					get_node("Text").show()
		return valid
	return true

func has_forced_action_result(turn):
	return self.current_rule != null

func handle_forced_action_result(turn):
	print("handling forced action result")
	update_rule()
	


func _input(event):
	if get_node("InputHandler").is_select(event):
		update_rule(true)
		

func has_player_turn_start_rule(turn):
	return self.player_turn_start_rules.has(turn)


func has_enemy_turn_end_rule(turn):
	return self.enemy_turn_end_rules.has(turn)
	
func has_enemy_turn_start_rule(turn):
	return self.enemy_turn_start_rules.has(turn)


func display_player_turn_start_rule(turn):
	self.current_rule = self.player_turn_start_rules[turn]
	update_rule()

func display_enemy_turn_start_rule(turn):
	self.current_rule = self.enemy_turn_start_rules[turn]
	update_rule()

func display_enemy_turn_end_rule(turn):
	self.current_rule = self.enemy_turn_end_rules[turn]
	update_rule()


func update_rule(next=false):
	set_process_input(false)
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
		get_node("AnimationPlayer 2").play("fade_out")
		yield(get_node("AnimationPlayer 2"), "finished")
		set_opacity(1)
		get_node("RuleOverlay").hide()
		get_node("Sprite").set_opacity(0.6)
		get_node("Sprite").hide()
		get_node("Light2D").hide()
		get_node("Text").hide()
		get_node("Text/TapLabel").hide()
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
				
			get_node("Text").set_global_pos(self.resolution/2)
			get_node("Text/Label").set_bbcode(line)
			get_node("Text").show()
			
			var filled_cont_text = continue_text % [rule.get_index(), rule.get_size()]
			get_node("Text/TapLabel").set_text(filled_cont_text)
			get_node("Text/TapLabel").show()
			if coords != null:
				if coords == Vector2(3, 4):
					get_node("Text").set_global_pos(self.resolution/2 + Vector2(0, -150))
				elif coords == Vector2(3, 3):
					get_node("Text").set_global_pos(self.resolution/2 + Vector2(0, 150))
				var new_pos = get_parent().get_node("Grid").locations[coords].get_global_pos()
				get_node("Sprite").set_opacity(0.8)
				get_node("Sprite").set_pos(new_pos)
				get_node("Sprite").show()
			else:
				get_node("RuleOverlay").show()
			
			print("is currently visible: ", is_visible())
			if !is_visible():
				get_node("AnimationPlayer 2").play("fade_in")
			
			get_node("Timer").set_wait_time(0.3)
			get_node("Timer").start()
			yield(get_node("Timer"), "timeout")
			
			set_process_input(true)

