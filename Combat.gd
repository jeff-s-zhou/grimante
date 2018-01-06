extends Node2D

const STATES = {"player_turn":0, "enemy_turn":1, "transitioning":3, "deploying":4, "instruction":5, "end":6}

onready var PLATFORMS = get_node("/root/global").PLATFORMS

var state = STATES.deploying
var enemy_waves = null
var tutorial = null
var enemy_reinforcements = {}
var instructions = []
var reinforcements = {}
var turn_count = 0
var level_schematic = null
var state_manager = null
var mid_forced_action = false
var desktop_flag = false

var has_active_star = false

var combat_resource = "res://Combat.tscn"

const outcome_screen_prototype = preload("res://UI/Desktop/OutcomeDisplay.tscn")

onready var Constants = get_node("/root/constants")

signal wave_deployed
signal next_pressed
signal reinforced
signal done_initializing

signal enemy_turn_done

signal deployed

signal animation_done

func _ready():
	var material = get_node("TransitionMask").get("material/material")
	material.set("shader_param/strength", 0)
	
	self.combat_resource = get_node("/root/global").combat_resource
	if get_node("/root/global").platform == PLATFORMS.PC:
		self.desktop_flag = true
	
	get_node("/root/AnimationQueue").reset()
	
	
	
	var screen_size = get_node("/root/global").get_resolution() #get_viewport().get_rect().size
	get_node("Grid").set_pos(Vector2(screen_size.x/2 - 310, screen_size.y/2- 350))
	#debug_full_roster()
	
	get_node("/root/AnimationQueue").connect("animation_count_update", self, "update_animation_count_display")

	self.level_schematic = get_node("/root/global").get_param("level").get_level()
	if self.level_schematic.tutorial != null:
		var tutorial_func = self.level_schematic.tutorial
		self.tutorial = tutorial_func.call_func()
		if self.tutorial != null:
			add_child(self.tutorial)
			print("adding tutorial")

	get_node("/root/DataLogger").log_start_attempt(self.level_schematic.id)
	
	#is here the big divide?

	self.enemy_waves = self.level_schematic.enemies

	self.reinforcements = self.level_schematic.reinforcements
		
	#we store the initial wave count as the first value in the array
	
	get_node("PauseMenu").initialize(self.level_schematic)
	
	get_node("PhaseShifter").initialize(self.level_schematic)
	
	get_node("InfoBar").initialize(self.level_schematic, get_node("ControlBar/Combat/StarBar"), self.level_schematic.flags)
	
	get_node("ControlBar").initialize(self.level_schematic.flags, self)
	
	get_node("/root/AssistSystem").initialize(self.level_schematic.flags)
	
	get_node("Grid").initialize(self.level_schematic.flags)
	
	if !get_node("/root/MusicPlayer").is_playing():
		get_node("/root/MusicPlayer").play()

	#key is the coords, value is the piece
	for key in self.level_schematic.allies.keys():
		initialize_piece(self.level_schematic.allies[key], false, key)
	
	#key is the unit's file, value is simply true
	var available_roster = get_node("/root/State").get_roster()
		
	
	if self.level_schematic.free_deploy:
		for file_name in available_roster:
			var prototype = load(file_name)
			#only add to the final hero select pieces that aren't already pre selected
			if !prototype in self.level_schematic.allies.values():
				initialize_piece(prototype, true)
	
	load_in_next_incoming(true)
	get_node("Grid").handle_incoming(true)
	load_in_next_incoming()
	get_node("Grid").display_incoming()
	
	get_node("AnimationPlayer").play("transition_in")
	yield(get_node("AnimationPlayer"), "finished")
	
	unpause()
		
	if self.level_schematic.free_deploy:
		get_node("DeployMessage").show()
		get_node("ControlBar").set_deploying(true)
		get_node("Grid").set_deploying(true, self.level_schematic.flags)
		
		for piece in get_node("Grid").pieces.values():
			piece.start_deploy_phase()

		#handle turn 0 tutorial popups before even deploying
		if self.tutorial != null and self.tutorial.has_player_turn_start_rule(get_turn_count()):
			pause()
			self.tutorial.display_player_turn_start_rule(get_turn_count())
			yield(self.tutorial, "rule_finished")
			unpause()
		
		yield(self, "deployed")
	
	#hiding the fifth unit select causes animations
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	
	get_node("Grid").set_deploying(false)
	get_node("ControlBar").set_deploying(false)
	get_node("DeployMessage").hide()
	
	for piece in get_node("Grid").pieces.values():
		piece.deploy()
	
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	get_node("PhaseShifter").animate_player_phase(self.turn_count)
	yield( get_node("PhaseShifter"), "animation_done" )
	
	get_node("ControlBar/Combat/EndTurnButton").set_disabled(false)
	
	start_player_phase()

	
func get_turn_count():
	return self.turn_count

func update_animation_count_display(count):
	get_node("AnimationCountLabel").set_text(str(count))

	
func debug_full_roster():
	var Berserker = load("res://PlayerPieces/BerserkerPiece.tscn")
	var Cavalier = load("res://PlayerPieces/CavalierPiece.tscn")
	var Archer = load("res://PlayerPieces/ArcherPiece.tscn")
	var Assassin = load("res://PlayerPieces/AssassinPiece.tscn")
	var Stormdancer = load("res://PlayerPieces/StormdancerPiece.tscn")
	var Pyromancer = load("res://PlayerPieces/PyromancerPiece.tscn")
	var FrostKnight = load("res://PlayerPieces/FrostKnightPiece.tscn")
	var Saint = load("res://PlayerPieces/SaintPiece.tscn")
	var Corsair = load("res://PlayerPieces/CorsairPiece.tscn")
	pass
	
func pause():
	set_process_input(false)
	get_node("ControlBar").set_disabled(true)
	

func unpause():
	set_process_input(true)
	#needed otherwise the control bar can still process the exact same inputs that unpaused lol
	get_node("Timer").set_wait_time(0.1) 
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	get_node("ControlBar").set_disabled(false)
	
func set_forced_action(flag):
	self.mid_forced_action = flag
	get_node("ControlBar").set_disabled(flag)

func debug_mode():
	get_node("Grid").debug()

func soft_copy_dict(source, target):
    for k in source.keys():
        target[k] = source[k]

func soft_copy_array(source, target):
	for item in source:
		target.push_back(item)

func initialize_piece(piece_prototype, on_bar=false, key=null):
	var new_piece = piece_prototype.instance()
	get_node("/root/State").add_to_roster(new_piece.get_filename())
	new_piece.set_opacity(0)
	new_piece.connect("invalid_move", self, "handle_invalid_move")
	new_piece.connect("shake", self, "screen_shake")
	new_piece.connect("small_shake", self, "small_screen_shake")
	new_piece.connect("big_shake", self, "big_screen_shake")
	new_piece.connect("animated_placed", self, "handle_piece_placed")	
	
	if on_bar:
		get_node("ControlBar").add_piece_on_bar(new_piece)
	else:
		var position
		if typeof(key) == TYPE_INT:
			position = get_node("Grid").get_bottom_of_column(key)
		else:
			position = key #that way when we need to we can specify by coordinates
		get_node("Grid").add_piece(position, new_piece)

	#these require the piece to have been added as a child
	new_piece.initialize(get_node("CursorArea"), self.level_schematic.flags) #placed afterwards because we might need the piece to be on the grid
	
	yield(new_piece.get_node("Tween"), "tween_complete")
	emit_signal("done_initializing")
	

func handle_piece_placed():
	print("handling piece placed")
	if self.tutorial != null:
		if self.tutorial.has_forced_action_result(self.turn_count):
			pause()
			if get_node("/root/AnimationQueue").is_animating():
				yield(get_node("/root/AnimationQueue"), "animations_finished")
			self.tutorial.handle_forced_action_result(self.turn_count)
			yield(self.tutorial, "rule_finished")
			set_forced_action(false)
			unpause()
		
		if self.tutorial.has_forced_action(self.turn_count):
			pause()
			if get_node("/root/AnimationQueue").is_animating():
				yield(get_node("/root/AnimationQueue"), "animations_finished")
			self.tutorial.display_forced_action(self.turn_count)
			unpause()
			set_forced_action(true)
			
		else:
			set_forced_action(false)
	
	#this has to be before the other or it's a race condition
	if get_node("ControlBar/Combat/StarBar").has_star():
		get_node("ControlBar/Combat/StarBar").star_flash(true)
		return
		
	#check if we can automatically end turn
	var player_pieces = get_tree().get_nodes_in_group("player_pieces")
	for player_piece in player_pieces:
		if !player_piece.is_placed():
			return
	
	end_turn()
#	if get_tree().get_nodes_in_group("player_pieces").size() > 0: #otherwise will have won
#		end_turn()
#	else:
#		pause() 

#	
#
func initialize_enemy_piece(coords, prototype, health, modifiers, animation_sequence=null):
	var enemy_piece = prototype.instance()
	get_node("Grid").add_child(enemy_piece)
	#get_node("Grid").add_piece(coords, enemy_piece)
	enemy_piece.initialize(health, modifiers, prototype)
	#enemy_piece.toggle_desktop(self.desktop_flag)
	enemy_piece.connect("broke_defenses", self, "damage_defenses")
	enemy_piece.connect("shake", self, "screen_shake")
	enemy_piece.connect("small_shake", self, "small_screen_shake")
	enemy_piece.connect("enemy_death", self, "handle_enemy_death")
	enemy_piece.check_global_seen()
	return enemy_piece
			

func end_turn():
	if self.state == STATES.end:
		return

	self.state = STATES.transitioning
	get_node("ControlBar/Combat/EndTurnButton").set_disabled(true)
	get_node("ControlBar/Combat/StarBar").star_flash(false)
	
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
		
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")

	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.placed(true)
		player_piece.clear_assist()
	get_node("/root/AssistSystem").clear_assist()
	get_node("Grid").end_turn_clear_state()
	get_node("PhaseShifter").animate_enemy_phase(self.turn_count)
	yield(get_node("PhaseShifter"), "animation_done")
	print("ending turn")
	enemy_phase()
	
func handle_deploy():
	if self.state == self.STATES.deploying:
		emit_signal("deployed")
	
	
func display_pause_menu():
		pause()
		get_node("PauseMenu").show()
	
		
func restart():
	pause()
	get_node("/root/AnimationQueue").stop()
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	get_node("/root/DataLogger").log_restart(self.level_schematic.id, self.turn_count)
	get_node("AnimationPlayer").play("transition_out_fast")
	yield(get_node("AnimationPlayer"), "finished")
	get_node("/root/global").goto_scene(self.combat_resource, {"level": self.level_schematic})


#called to check if a mouse is currently inside the area of a piece
func check_hovered():
	var hovered = get_node("CursorArea").get_piece_hovered()
	if hovered:
		hovered.hovered()
		
func get_hovered():
	var hovered = get_node("CursorArea").get_piece_or_location_hovered()
	return hovered


func _input(event):
	computer_input(event)
	

func computer_input(event):
	#select a unit
	if get_node("InputHandler").is_select(event):
		print("handling select input")
		if self.state == STATES.player_turn or STATES.deploying:
			instant_lighten()
			var has_selected = get_node("Grid").selected != null
			var hovered = get_node("CursorArea").get_piece_or_location_hovered()
			if hovered and hovered.is_targetable():
				print("detected hovered and targetable on input")
				var star_bar = get_node("ControlBar/Combat/StarBar")
				#if a star is active, handle it appropriately
				if self.has_active_star:
					star_bar.handle_active_star(hovered, event)
					set_active_star(false)
				else:
					#if during a tutorial level, make sure move is as intended
					if self.tutorial != null:
						if self.tutorial.move_is_valid(get_turn_count(), hovered.coords):
							hovered.input_event(event, has_selected)
						else:
							print("not valid??")
					else:
						hovered.input_event(event, has_selected)
			
			#we add this case so we don't trigger the invalid move during a forced action
			elif self.tutorial != null and self.tutorial.has_forced_action(get_turn_count()):
				pass
			
			elif has_selected:
				handle_invalid_move()
				get_node("Grid").deselect()
			
	
	#don't handle any other input during forced actions
	if self.mid_forced_action:
		return

			
	elif get_node("InputHandler").is_deselect(event): 
		if get_node("Grid").selected != null:
			get_node("Grid").deselect()

	
	elif get_node("InputHandler").is_ui_accept(event):
		if self.state == self.STATES.deploying:
			emit_signal("deployed")
		if self.state == self.STATES.player_turn:
			end_turn()
			
	elif event.is_action("detailed_description"):
		if event.is_pressed() and !event.is_echo():
			var hovered_piece = get_node("CursorArea").get_piece_hovered()
			if hovered_piece == null:
				return
			
			elif hovered_piece.side == "ENEMY":
				hovered_piece.set_seen(true)
				get_node("InfoOverlay").display_enemy_info(hovered_piece)
			else: #elif hovered_piece.side == "PLAYER"
				get_node("InfoOverlay").display_player_info(hovered_piece)
			
			pause()
			yield(get_node("InfoOverlay"), "description_finished")
			unpause()


	elif event.is_action("debug_level_skip") and event.is_pressed():
		if(self.level_schematic.next_level != null):
			pause()
			if get_node("/root/AnimationQueue").is_animating():
				yield(get_node("/root/AnimationQueue"), "animations_finished")
			get_node("/root/AnimationQueue").stop()
			get_node("/root/global").goto_scene(self.combat_resource, {"level": self.level_schematic.next_level})
			
			
	elif event.is_action("restart") and event.is_pressed():
		restart()

			
	elif event.is_action("test_action") and event.is_pressed():
		print(get_tree().get_nodes_in_group("player_pieces"))
		get_node("/root/AnimationQueue").debug()
		debug_mode()
		for enemy_piece in get_tree().get_nodes_in_group("enemy_pieces"):
			enemy_piece.debug()
			
		for location in get_node("Grid").locations.values():
			location.debug()
			
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.debug()
			
	elif event.is_action("test_action2") and event.is_pressed():
		pass

		#print(get_node("Grid").pieces)


func _process(delta):
	get_node('FpsLabel').set_text(str(OS.get_frames_per_second()))

		
func enemy_phase():
	if self.state == STATES.enemy_turn: 
	#this fixes some obscure bug where the handle_piece_placed and manually ending turn both trigger?
		return
	self.state = STATES.enemy_turn
	if self.tutorial != null and self.tutorial.has_enemy_turn_start_rule(get_turn_count()):
		self.tutorial.display_enemy_turn_start_rule(get_turn_count())
		pause()
		yield(self.tutorial, "rule_finished")
		unpause()

	var enemy_pieces = get_enemies(false)
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_start()
	
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")
		
	enemy_phase_helper(false)
	yield(self, "enemy_turn_done")
	
	enemy_phase_helper(true)
	yield(self, "enemy_turn_done")
	
	enemy_pieces = get_enemies(false)
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_attack_update()

	#if there are enemy pieces, wait for them to finish
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	
	var enemy_pieces = get_enemies(false)
	for enemy in enemy_pieces:
		enemy.turn_end()
	
	get_node("Timer2").set_wait_time(0.25)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	get_node("Grid").handle_incoming()
	load_in_next_incoming()
	get_node("Grid").display_incoming()
		
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	
	
	get_node("Timer2").set_wait_time(0.5)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	if get_tree().get_nodes_in_group("enemy_pieces").size() == 0: 
		player_win()
		return

	elif get_tree().get_nodes_in_group("player_pieces").size() == 0 or get_node("InfoBar").check_timeout(self.turn_count):
		enemy_win()
		return
	
	if self.tutorial != null and self.tutorial.has_enemy_turn_end_rule(get_turn_count()):
		self.tutorial.display_enemy_turn_end_rule(get_turn_count())
		pause()
		yield(self.tutorial, "rule_finished")
		unpause()
	
	if self.state != STATES.end:
		get_node("PhaseShifter").animate_player_phase(self.turn_count)
		yield( get_node("PhaseShifter"), "animation_done")
		get_node("InfoBar").update(self.turn_count)
		start_player_phase()


func enemy_phase_helper(double_time_turn):
	var enemy_pieces = get_enemies(double_time_turn)
	if enemy_pieces != []:

		for enemy_piece in enemy_pieces:
			enemy_piece.turn_update()
			
		if(get_node("/root/AnimationQueue").is_animating()):
			yield(get_node("/root/AnimationQueue"), "animations_finished")
	
	#needed so the signal isn't sent out too early wtfffff
	get_node("Timer2").set_wait_time(0.05)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	emit_signal("enemy_turn_done")


func get_enemies(double_time_turn):
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	if double_time_turn:
		var double_time_enemies = []
		for enemy_piece in enemy_pieces:
			if enemy_piece.double_time:
				double_time_enemies.append(enemy_piece)
		double_time_enemies.sort_custom(self, "_sort_by_y_axis")
		return double_time_enemies
	else:
		enemy_pieces.sort_custom(self, "_sort_by_y_axis")
		return enemy_pieces


func start_player_phase():
	self.turn_count += 1
	get_node("ControlBar/Combat/EndTurnButton").set_disabled(false)

		
	if self.tutorial != null and self.tutorial.has_player_turn_start_rule(get_turn_count()):
		self.tutorial.display_player_turn_start_rule(get_turn_count())
		pause()
		yield(self.tutorial, "rule_finished")
		unpause()

	get_node("/root/AssistSystem").reset_combo()
	if self.reinforcements.has(get_turn_count()):
		reinforce()
		yield(self, "reinforced")

	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.turn_update()
	
	#if final turn, gain bonus star
	if self.turn_count == self.level_schematic.num_turns:
		get_node("ControlBar/Combat/StarBar").add_star()
	
	if self.tutorial != null and self.tutorial.has_forced_action(self.turn_count):
		set_forced_action(true)
		self.tutorial.display_forced_action(get_turn_count())

	self.state = STATES.player_turn


func reinforce():
	var reinforcement_wave = self.reinforcements[get_turn_count()]
	for key in reinforcement_wave.keys():
		var prototype = reinforcement_wave[key]
		initialize_piece(prototype, false, key)
		yield(self, "done_initializing")
	emit_signal("reinforced")

func screen_shake():
	get_node("ShakeCamera").shake(0.6, 28, 15)
	#get_node("ShakeCamera").shake(0.6, 30, 12)
	
func small_screen_shake():
	get_node("ShakeCamera").shake(0.4, 24, 5)

func big_screen_shake():
	get_node("ShakeCamera").shake(0.8, 36, 25)

func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false


func load_in_next_incoming(zero_wave=false):
	load_in_next_wave(zero_wave)
	load_in_next_traps(zero_wave)


func load_in_next_wave(zero_wave=false):
	var wave
	if zero_wave:
		wave = self.enemy_waves.get_next_summon(self.turn_count)
	else:
		wave = self.enemy_waves.get_next_next_summon(self.turn_count)
	
	if wave != null:
		for key in wave.keys():
			var coords = null
			if typeof(key) == TYPE_INT: #this lets us just specify the top of rows
				coords = get_node("Grid").get_top_of_column(key)
			else:
				coords = key
			var prototype_parts = wave[coords]
			var prototype = prototype_parts["prototype"]
			var hp = prototype_parts["hp"]
			var modifiers = prototype_parts["modifiers"]

			var enemy_piece = initialize_enemy_piece(coords, prototype, hp, modifiers)
			get_node("Grid").set_reinforcement(coords, enemy_piece)


func load_in_next_traps(zero_wave=false):
	var traps_range
	if zero_wave:
		traps_range = self.level_schematic.get_traps(0)
	else:
		traps_range = self.level_schematic.get_traps(self.turn_count + 1)
	
	if traps_range != null:
		for coords in traps_range:
			get_node("Grid").locations[coords].set_trap()

		
#called IN ADDITION to handle_enemy_death on a boss dying
func handle_boss_death():
	if get_tree().get_nodes_in_group("boss_pieces").size() == 0:
		player_win()


func handle_enemy_death(coords):
	if get_node("/root/global").platform == PLATFORMS.PC:
		get_node("ControlBar/Combat/StarBar").handle_enemy_death()
	else:
		get_node("InfoBar").handle_enemy_death()
	get_node("Grid").handle_enemy_death(coords)
	if get_tree().get_nodes_in_group("enemy_pieces").size() == 0:
		player_win()


func player_win():
	print("calling player win")
	if self.state == STATES.end:
		return
	
	self.state = STATES.end
	pause()
	
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
		
	get_node("/root/AnimationQueue").stop()
	
	get_node("/root/DataLogger").log_win(self.level_schematic.id, self.turn_count)
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	if self.level_schematic.is_sub_level():
		get_node("AnimationPlayer").play("transition_out_fast")
		yield(get_node("AnimationPlayer"), "finished")
		get_node("/root/global").goto_scene(self.combat_resource, {"level": self.level_schematic.next_level})
	else:
		var win_screen = self.outcome_screen_prototype.instance()
		add_child(win_screen)
		win_screen.initialize_victory(self.level_schematic.next_level, self.level_schematic, self.turn_count)
		win_screen.fade_in()


func enemy_win():
	if self.state == STATES.end:
		return
		
	self.state = STATES.end
	pause()
	if self.level_schematic.seamless:
		get_node("AnimationPlayer").play("transition_out_fast")
		yield(get_node("AnimationPlayer"), "finished")
		restart()
	else:
		get_node("/root/AnimationQueue").stop()
		get_node("/root/DataLogger").log_lose(self.level_schematic.id, self.turn_count)
		
		print(get_node("/root/AnimationQueue").is_animating())
		if get_node("/root/AnimationQueue").is_animating():
			yield(get_node("/root/AnimationQueue"), "animations_finished")
		
		get_node("Timer2").set_wait_time(0.5)
		get_node("Timer2").start()
		yield(get_node("Timer2"), "timeout")
#
		var lose_screen = self.outcome_screen_prototype.instance()
		add_child(lose_screen)
		lose_screen.initialize_defeat(self.level_schematic.next_level, self.level_schematic)
		lose_screen.fade_in()
#	

func damage_defenses():
	enemy_win()
		
func display_overlay(unit_name):
	get_node("/root/AnimationQueue").enqueue(get_node("OverlayDisplayer"), "animate_display_overlay", true, [unit_name])

#called when we want no interaction from the player, like when the settings screen is opened
#opacity of the darken is set to 0.7 in the scene, but the blur is set to 1
func blur_darken(time=0.3):
	get_node("BlurDarkenLayer").animate_darken(time)
	yield(get_node("BlurDarkenLayer"), "animation_done")
	emit_signal("animation_done")
	
func blur_lighten(time=0.3):
	get_node("BlurDarkenLayer").animate_lighten(time)
	yield(get_node("BlurDarkenLayer"), "animation_done")
	emit_signal("animation_done")



func darken(time=0.4, amount=0.3, delay=0.0):
	get_node("Tween").interpolate_property(get_node("DarkenLayer"), "visibility/opacity", 0, amount, time, Tween.TRANS_SINE, Tween.EASE_IN, delay)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	
func instant_lighten():
	get_node("DarkenLayer").set_opacity(0)

func lighten(time=0.4):
	var amount = get_node("DarkenLayer").get_opacity()
	get_node("Tween").interpolate_property(get_node("DarkenLayer"), "visibility/opacity", amount, 0, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	

func transition_out():
	get_node("AnimationPlayer").play("transition_out_fast")
	yield(get_node("AnimationPlayer"), "finished")
	emit_signal("animation_done")
	
func handle_invalid_move():
	get_node("SamplePlayer").play("error")
	#get_node("InvalidMoveIndicator/AnimationPlayer").play("flash")
	
func set_active_star(flag):
	self.has_active_star = flag
	get_node("CursorArea").set_star_cursor(flag)
	get_node("Grid").set_revive_tiles(flag)
