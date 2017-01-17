
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"



const STATES = {"player_turn":0, "enemy_turn":1, "transitioning":2, "game_start":3, "instruction":4}
var state = STATES.game_start
var enemy_waves = []
var instructions = []
var reinforcements = {}
var turn_count = 0
var level = null
var reload_level = null
var next_level = null

var tabbed_flag #to check if a current description is tabbed in

var enemy_tooltip_flag
var player_info_flag

signal enemy_turn_finished
signal wave_deployed
signal next_pressed
signal reinforced
signal done_initializing

signal animation_done

var archer = null
var assassin = null

func _ready():
	set_process(true)
	set_process_input(true)
	
	get_node("Timer").set_active(false)
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2(200, 140))
	
	get_node("Grid").debug()
	
	get_node("TutorialPopup").set_pos(Vector2((get_viewport_rect().size.width)/2, -100))
	get_node("Button").connect("pressed", self, "end_turn")
	
	get_node("Button").set_disabled(true)
	
	get_node("ComboSystem/ComboPointsLabel").set_opacity(0)
	get_node("WavesDisplay/WavesLabel").set_opacity(0)
	
	get_node("LivesSystem").set_lives(3)

	
	level = get_node("/root/global").get_param("level")

	var temp_allies = {}
	soft_copy_dict(level["allies"], temp_allies)
	var allies = temp_allies
	for key in allies.keys():
		initialize_piece(allies[key], key)
	
	var temp_enemies = []
	soft_copy_array(level["enemies"], temp_enemies)
	self.enemy_waves = temp_enemies
	
	self.reinforcements = level["reinforcements"]
	
	var temp_instructions = []
	soft_copy_array(level["instructions"], temp_instructions)
	self.instructions = temp_instructions
	
	self.next_level = level["next_level"]
	
	#we store the initial wave count as the first value in the array
	var initial_deploy_count = level["initial_deploy_count"]
	
	if level.has("flags"):
		var flags = level["flags"]
		for flag in flags:
			if flag == "ultimates_enabled_flag":
				get_node("/root/global").ultimates_enabled_flag = true
	
	for i in range(0, initial_deploy_count):
		if self.enemy_waves.size() > 0:
			deploy_wave()
			yield(self, "wave_deployed")
			
	get_node("WavesDisplay/WavesLabel").set_text(str(self.enemy_waves.size()))
	get_node("WavesDisplay/WavesLabel").set_opacity(1)
	get_node("ComboSystem/ComboPointsLabel").set_opacity(1)

	get_node("PhaseShifter").player_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	player_phase_start()

func soft_copy_dict(source, target):
    for k in source.keys():
        target[k] = source[k]

func soft_copy_array(source, target):
	for item in source:
		target.push_back(item)

	
func initialize_piece(piece, key):
	var new_piece = piece.instance()
	if new_piece.UNIT_TYPE == "Archer":
		self.archer = new_piece
	elif new_piece.UNIT_TYPE == "Assassin":
		self.assassin = new_piece
	new_piece.set_opacity(0)
	new_piece.connect("invalid_move", self, "handle_invalid_move")
	new_piece.connect("pre_attack", self, "handle_archer_ultimate")
	new_piece.connect("shake", self, "screen_shake")
	
	
	var position
	if typeof(key) == TYPE_INT:
		position = get_node("Grid").get_bottom_of_column(key)
	else:
		position = key #that way when we need to we can specify by coordinates
	
	get_node("Grid").add_piece(position, new_piece)
	new_piece.initialize(get_node("CursorArea")) #placed afterwards because we might need the piece to be on the grid	
	new_piece.check_global_seen()
	new_piece.animate_summon()
	yield(new_piece.get_node("Tween"), "tween_complete")
	emit_signal("done_initializing")
	
	
func end_turn():
	
	self.state = STATES.transitioning
	
	if get_node("/root/AnimationQueue").is_busy():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	else:
		get_node("Timer2").set_wait_time(0.2)
		get_node("Timer2").start()
		yield(get_node("Timer2"), "timeout")
	
	get_node("Button").set_disabled(true)
	get_node("TutorialTooltip").reset()
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.placed()
	get_node("PhaseShifter").enemy_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	get_node("ComboSystem").player_turn_ended()
	self.state = STATES.enemy_turn

func _input(event):
	if event.is_action("deselect") and event.is_pressed(): 
		if get_node("Grid").selected:
			get_node("Grid").selected.deselect()
			get_node("Grid").selected = null
			get_node("Grid").reset_highlighting(true)
			get_node("Grid").reset_prediction()
			
	elif event.is_action("detailed_description") :
		if event.is_pressed() and !event.is_echo():
			var hovered_piece = get_node("CursorArea").get_piece_hovered()
			if hovered_piece == null:
				return
			
			elif hovered_piece.side == "ENEMY":
				hovered_piece.set_seen(true)
				self.enemy_tooltip_flag = true
				get_node("Tooltip").set_info(hovered_piece.unit_name, hovered_piece.hover_description, hovered_piece.modifier_descriptions)
				get_node("Tooltip").set_pos(get_viewport().get_mouse_pos())
				get_node("Tooltip").set_opacity(1)
			else: #elif hovered_piece.side == "PLAYER"
				self.player_info_flag = true
				hovered_piece.set_seen(true)
				get_node("PhaseShifter/AnimationPlayer").play("start_blur")
				darken(0.2, 0.1)
				get_node("PlayerPieceInfo").set_info(hovered_piece.unit_name, hovered_piece.overview_description, \
	 			hovered_piece.attack_description, hovered_piece.passive_description, hovered_piece.ultimate_description)
				get_node("PlayerPieceInfo").show()


		elif !event.is_pressed() and !event.is_echo():
			if self.enemy_tooltip_flag:
				self.enemy_tooltip_flag = false
				get_node("Tooltip").set_opacity(0)
				get_node("Tooltip").set_pos(Vector2(-500, -500))
			elif self.player_info_flag: #elif hovered_piece.side == "PLAYER"
				self.player_info_flag = false
				lighten(0.2, 0.1)
				get_node("PhaseShifter/AnimationPlayer").play("end_blur")
				get_node("PlayerPieceInfo").hide()


	elif event.is_action("debug_level_skip") and event.is_pressed():
		if(self.next_level != null):
			get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.next_level})
			
			
	elif event.is_action("restart") and event.is_pressed():
		get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level})
	
	elif event.is_action("toggle_fullscreen") and event.is_pressed():
		if OS.is_window_fullscreen():
			OS.set_window_fullscreen(false)
			OS.set_window_maximized(true)
		else:
			OS.set_window_maximized(false)
			OS.set_window_fullscreen(true)

func _process(delta):
	
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	if enemy_pieces.size() == 0 and self.enemy_waves.size() == 0:
		player_win()

	if self.state == STATES.player_turn:
		
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			if !player_piece.is_placed():
				return
				
		if !get_node("Timer").is_active():
			get_node("Timer").set_active(true)
			get_node("Timer").set_wait_time(0.4)
			get_node("Timer").start()
			
		elif get_node("Timer").get_time_left() <= 0.1:
			
			#make sure the animation queue is clear
			if get_node("/root/AnimationQueue").is_busy():
				return
				
			#make sure trailing, non-sequential animations are done like flyover text
			for enemy_piece in get_tree().get_nodes_in_group("enemy_pieces"):
				if enemy_piece.mid_trailing_animation:
					return
			get_node("Timer").set_active(false)
			end_turn()
			
		
	elif self.state == STATES.enemy_turn:
		enemy_phase(enemy_pieces)
		self.state = STATES.transitioning

	elif self.state == STATES.transitioning:
		pass
		
		
func enemy_phase(enemy_pieces):
	
	enemy_pieces.sort_custom(self, "_sort_by_y_axis") #ensures the pieces in front move first
	for enemy_piece in enemy_pieces:
		enemy_piece.aura_update()
	for enemy_piece in enemy_pieces:
		print("in enemy_phase: " + enemy_piece.unit_name)
		enemy_piece.turn_update()
	
	#if there are enemy pieces, wait for them to finish
	if(get_tree().get_nodes_in_group("enemy_pieces").size() > 0):
		yield(get_node("/root/AnimationQueue"), "animations_finished")


	if self.enemy_waves.size() > 0:
		deploy_wave()
		yield(self, "wave_deployed")
	
	get_node("Timer2").set_wait_time(0.8)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	if get_tree().get_nodes_in_group("player_pieces").size() == 0:
		enemy_win()
	
	get_node("PhaseShifter").player_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	
	player_phase_start()
	

func player_phase_start():
	self.turn_count += 1
	if self.reinforcements.has(self.turn_count):
		reinforce()
		yield(self, "reinforced")
	if (self.instructions.size() > 0):
		handle_instructions()
		yield(self, "next_pressed")
	
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.turn_update()

	self.state = STATES.player_turn
	get_node("Button").set_disabled(false)
	
func reinforce():
	var reinforcement_wave = self.reinforcements[self.turn_count]
	for key in reinforcement_wave.keys():
		var prototype = reinforcement_wave[key]
		initialize_piece(prototype, key)
		yield(self, "done_initializing")
	emit_signal("reinforced")

func handle_instructions():
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	var instruction = self.instructions[0]
	self.instructions.pop_front()
	var tip_text = instruction["tip_text"]
	var objective_text = instruction["objective_text"]
	#if there's no instruction text in the first place, piss off
	if !tip_text and !objective_text:
		emit_signal("next_pressed")
		return
		
	var popup = get_node("TutorialPopup")
	popup.set_text(tip_text, objective_text)
		
	get_node("PhaseShifter/AnimationPlayer").play("start_blur")
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	
	
	get_node("Tween").interpolate_property(popup, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	
	var end_pos = popup.get_pos() + Vector2(0, get_viewport_rect().size.height/2 + 100)
	get_node("Tween").interpolate_property(popup, "transform/pos",popup.get_pos(), end_pos, 1, Tween.TRANS_BACK, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	popup.transition_in()
	yield(popup, "done")
	
	yield(popup, "next")
	popup.transition_out()
	get_node("Tween").interpolate_property(popup, "visibility/opacity", 1, 0, 1, Tween.TRANS_SINE, Tween.EASE_IN)
	
	var end_pos = Vector2((get_viewport_rect().size.width)/2, -100)
	get_node("Tween").interpolate_property(popup, "transform/pos", popup.get_pos(), end_pos, 1, Tween.TRANS_BACK, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("PhaseShifter/AnimationPlayer").play("end_blur")
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	emit_signal("next_pressed")
	
	
	
	if instruction.has("tooltip"):
		get_node("TutorialTooltip").set_tooltip(instruction["tooltip"])
	elif instruction.has("tooltips"):
		get_node("TutorialTooltip").set_tooltips(instruction["tooltips"])

func screen_shake():
	get_node("ShakeCamera").shake(0.5, 30, 4)


func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false
		
func deploy_wave():
	var wave = self.enemy_waves[0]
	self.enemy_waves.pop_front()
	for key in wave.keys():
		
		var prototype_parts = wave[key]
		var prototype = prototype_parts["prototype"]
		var health = prototype_parts["health"]
		var modifiers = prototype_parts["modifiers"]
		
		var enemy_piece = prototype.instance()
		enemy_piece.initialize(health)
		
		
		enemy_piece.connect("broke_defenses", self, "damage_defenses")

		var position
		if typeof(key) == TYPE_INT:
			position = get_node("Grid").get_top_of_column(key)
		else:
			position = key #that way when we need to we can specify by coordinates
		
		#push any player pieces if they're on the spawn point
		if(get_node("Grid").pieces.has(position)):
			get_node("Grid").pieces[position].push(Vector2(0, 1))
		get_node("Grid").add_piece(position, enemy_piece)
		
		if modifiers != null:
			print("caught modifiers!")
			for modifier in modifiers:
				print(modifier)
				if modifier == get_node("/root/constants").enemy_modifiers["Poisonous"]:
					enemy_piece.set_deadly(true)
				elif modifier == get_node("/root/constants").enemy_modifiers["Shield"]:
					enemy_piece.set_shield(true)


		enemy_piece.get_node("Sprinkles").set_particle_endpoint(get_node("ComboSystem/ComboPointsLabel").get_global_pos())
		enemy_piece.check_global_seen()
		enemy_piece.animate_summon()
		yield(enemy_piece.get_node("Tween"), "tween_complete" )
		get_node("WavesDisplay/WavesLabel").set_text(str(self.enemy_waves.size()))

	emit_signal("wave_deployed")

func player_win():
	set_process(false)
	self.state = STATES.transitioning
	if get_node("/root/AnimationQueue").is_busy():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	for enemy_piece in get_tree().get_nodes_in_group("enemy_pieces"):
		if enemy_piece.mid_trailing_animation:
			return
	get_node("Timer2").set_wait_time(3.0)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	get_node("/root/global").goto_scene("res://WinScreen.tscn", {"level":self.next_level})
	
func enemy_win():
	set_process(false)
	self.state = STATES.transitioning
	if get_node("/root/AnimationQueue").is_busy():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	for enemy_piece in get_tree().get_nodes_in_group("enemy_pieces"):
		if enemy_piece.mid_trailing_animation:
			return
	get_node("Timer2").set_wait_time(0.6)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	get_node("/root/global").goto_scene("res://LoseScreen.tscn", {"level":self.level})
	
	
func damage_defenses():
	get_node("LivesSystem").lose_lives(1)
	if get_node("LivesSystem").lives == 0:
		enemy_win()

func darken(amount=0.3, time=0.4):
	get_node("Tween").interpolate_property(get_node("DarkenLayer"), "visibility/opacity", 0, amount, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")

func lighten(amount=0.3, time=0.4):
	get_node("Tween").interpolate_property(get_node("DarkenLayer"), "visibility/opacity", amount, 0, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")

func handle_invalid_move():
	get_node("SamplePlayer").play("error")
	get_node("InvalidMoveIndicator/AnimationPlayer").play("flash")
	
func handle_archer_ultimate(attack_coords):
	if self.archer != null and self.archer.ultimate_flag:
		self.archer.trigger_ultimate(attack_coords)
		
func handle_assassin_passive(attack_coords):
	if self.assassin != null:
		self.assassin.trigger_passive(attack_coords)
	
