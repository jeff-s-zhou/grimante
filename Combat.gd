extends Node2D

const STATES = {"player_turn":0, "enemy_turn":1, "transitioning":3, "deploying":4, "instruction":5, "end":6}

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
var has_active_star = false

var assassin = null

onready var Constants = get_node("/root/constants")


signal wave_deployed
signal next_pressed
signal reinforced
signal done_initializing

signal deployed

signal animation_done

func _ready():
	get_node("/root/AnimationQueue").reset()
	get_node("/root/global").load_state()
	get_node("Timer").set_active(false)
	get_node("Grid").set_pos(Vector2(73, 270))
	#get_node("Grid").set_pos(Vector2(400, 250))
	#debug_mode()
	#debug_full_roster()
	
	get_node("RestartBar").connect("bar_filled", self, "restart")
	
	get_node("/root/AnimationQueue").connect("animation_count_update", self, "update_animation_count_display")
	
	get_node("TutorialPopup").set_pos(Vector2((get_viewport_rect().size.width)/2, -100))
	get_node("AssistSystem").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height - 100))
#

	self.level_schematic = get_node("/root/global").get_param("level").get_level()
	if self.level_schematic.tutorial != null:
		var tutorial_func = self.level_schematic.tutorial
		self.tutorial = tutorial_func.call_func()
		if self.tutorial != null:
			add_child(self.tutorial)

	get_node("/root/DataLogger").log_start_attempt(self.level_schematic.name)
	
	
	#is here the big divide?

	self.enemy_waves = self.level_schematic.enemies

	self.reinforcements = self.level_schematic.reinforcements
		
	#we store the initial wave count as the first value in the array

	if self.level_schematic.end_conditions.has(constants.end_conditions.Timed):
		self.state_manager = load("res://UI/TimedSystem.tscn").instance()
	elif self.level_schematic.end_conditions.has(constants.end_conditions.Sandbox):
		self.state_manager = load("res://UI/TimedSystem.tscn").instance()
	else:
		self.state_manager= load("res://UI/ClearRoomSystem.tscn").instance()

	add_child(self.state_manager)
	self.state_manager.initialize(self.level_schematic, get_node("ControlBar/StarBar"), self.level_schematic.flags)
	
	get_node("ControlBar").initialize(self.level_schematic.flags, self)
	
	get_node("AssistSystem").initialize(self.level_schematic.flags)
	
	get_node("Grid").initialize(self.level_schematic.flags)

	#key is the coords, value is the piece
	for key in self.level_schematic.allies.keys():
		initialize_piece(self.level_schematic.allies[key], false, key)
	
	#key is the unit, value is simply true
	var available_roster = get_node("/root/global").available_unit_roster.keys()
	if self.level_schematic.free_deploy:
		for prototype in available_roster:
			#only add to the final hero select pieces that aren't already pre selected
			if !prototype in self.level_schematic.allies.values():
				initialize_piece(prototype, true)
	
	load_in_next_wave(true)
	deploy_wave()
	load_in_next_wave()
	display_wave_preview()
	
	set_process(true)
	set_process_input(true)	
		
	if self.level_schematic.free_deploy:
		get_node("ControlBar/DeployButton").show()
		get_node("Grid").set_deploying(true, self.level_schematic.flags)
		
		for piece in get_node("Grid").pieces.values():
			piece.start_deploy_phase()
			
		for location in get_node("Grid").locations.values():
			location.start_deploy_phase()
		
		#handle turn 0 tutorial popups before even deploying
		if self.tutorial != null and self.tutorial.has_player_turn_start_rule(get_turn_count()):
			set_process_input(false)
			set_process(false)
			self.tutorial.display_player_turn_start_rule(get_turn_count())
			yield(self.tutorial, "rule_finished")
			set_process_input(true)
			set_process(true)
		
		yield(self, "deployed")
	
	#hiding the fifth unit select causes animations
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	
	
	get_node("ControlBar/DeployButton").hide()
	get_node("ControlBar/EndTurnButton").show()
	get_node("Grid").set_deploying(false)
	
	for piece in get_node("Grid").pieces.values():
		piece.deploy()
	for location in get_node("Grid").locations.values():
		location.deploy()
	
	
	
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	get_node("PhaseShifter").player_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	
	get_node("ControlBar/EndTurnButton").set_disabled(false)
	
	start_player_phase()
	
	
func soft_reset():
	set_process(false)
	set_process_input(false)
	
	self.state = STATES.deploying
	self.enemy_waves = null
	self.tutorial = null
	self.enemy_reinforcements = {}
	self.instructions = []
	self.reinforcements = {}
	self.mid_forced_action = false
	self.has_active_star = false
	self.turn_count = 0
	#self.assassin = null
	
	#key is the coords, value is the piece
	for key in self.level_schematic.allies.keys():
		initialize_piece(self.level_schematic.allies[key], false, key)


	self.state_manager.soft_reset(self.level_schematic)
	
	self.enemy_waves = self.level_schematic.enemies

	self.reinforcements = self.level_schematic.reinforcements
	
	load_in_next_wave(true)
	deploy_wave()
	load_in_next_wave()
	display_wave_preview()
	
	set_process(true)
	set_process_input(true)
	#start_player_phase()


	
func get_turn_count():
	return self.turn_count
	
func set_active_star(flag):
	self.has_active_star = flag
#	
#
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
	var roster = {Berserker: true, Cavalier: true, Archer: true, Assassin: true, Corsair: true}
	get_node("/root/global").available_unit_roster = roster

func debug_mode():
	get_node("Grid").debug()

func soft_copy_dict(source, target):
    for k in source.keys():
        target[k] = source[k]

func soft_copy_array(source, target):
	for item in source:
		target.push_back(item)

#called on its own to initialize Crusader alter ego
func initialize_crusader(new_piece):
	new_piece.set_opacity(0)
	new_piece.connect("invalid_move", self, "handle_invalid_move")
	new_piece.connect("shake", self, "screen_shake")
	new_piece.connect("small_shake", self, "small_screen_shake")
	new_piece.connect("animated_placed", self, "handle_piece_placed")
	get_node("Grid").add_child(new_piece)
	new_piece.initialize(get_node("CursorArea"), self.level_schematic.flags) #placed afterwards because we might need the piece to be on the grid	

func initialize_piece(piece, on_bar=false, key=null):
	if !get_node("/root/global").available_unit_roster.has(piece):
		get_node("/root/global").available_unit_roster[piece] = true
	
	var new_piece = piece.instance()
	new_piece.set_opacity(0)
	new_piece.connect("invalid_move", self, "handle_invalid_move")
	new_piece.connect("shake", self, "screen_shake")
	new_piece.connect("small_shake", self, "small_screen_shake")
	new_piece.connect("animated_placed", self, "handle_piece_placed")	
	
	if new_piece.UNIT_TYPE == "Assassin":
		self.assassin = new_piece
	
	if on_bar:
		get_node("Grid").add_piece_on_bar(new_piece)
	else:
		var position
		if typeof(key) == TYPE_INT:
			position = get_node("Grid").get_bottom_of_column(key)
		else:
			position = key #that way when we need to we can specify by coordinates
		get_node("Grid").add_piece(position, new_piece)

	#these require the piece to have been added as a child
	new_piece.initialize(get_node("CursorArea"), self.level_schematic.flags) #placed afterwards because we might need the piece to be on the grid
	
	new_piece.animate_summon()
	yield(new_piece.get_node("Tween"), "tween_complete")
	emit_signal("done_initializing")
	

func handle_piece_placed():
	if self.tutorial != null:
		print("handling piece placed?")
		if self.tutorial.has_forced_action_result(self.turn_count):
			print("handling forced action result")
			set_process_input(false)
			set_process(false)
			if get_node("/root/AnimationQueue").is_animating():
				yield(get_node("/root/AnimationQueue"), "animations_finished")
			self.tutorial.handle_forced_action_result(self.turn_count)
			yield(self.tutorial, "rule_finished")
			self.mid_forced_action = false
			set_process_input(true)
			set_process(true)
		
		if self.tutorial.has_forced_action(self.turn_count):
			self.mid_forced_action = true
			set_process_input(false)
			set_process(false)
			if get_node("/root/AnimationQueue").is_animating():
				yield(get_node("/root/AnimationQueue"), "animations_finished")
			self.tutorial.display_forced_action(self.turn_count)
			set_process_input(true)
			set_process(true)
			
		else:
			self.mid_forced_action = false


	#shouldn't interfere with any other forced actions, since it'll only end when all pieces are placed
	if !get_node("ControlBar/StarBar").has_star():
		#check if we can automatically end turn
		var player_pieces = get_tree().get_nodes_in_group("player_pieces")
		for player_piece in player_pieces:
			if !player_piece.is_placed():
				return
		end_turn()

#	
#
func initialize_enemy_piece(coords, prototype, health, modifiers, animation_sequence=null):
	var enemy_piece = prototype.instance()
	get_node("Grid").add_child(enemy_piece)
	#get_node("Grid").add_piece(coords, enemy_piece)
	enemy_piece.initialize(health, modifiers, prototype)
	enemy_piece.connect("broke_defenses", self, "damage_defenses")
	enemy_piece.connect("shake", self, "screen_shake")
	enemy_piece.connect("small_shake", self, "small_screen_shake")
	enemy_piece.connect("enemy_death", self.state_manager.get_node("StarSubsystem"), "add_kill_count")
	enemy_piece.check_global_seen()
	return enemy_piece
			

func end_turn():
	print("ending turn")
	self.state = STATES.transitioning
	get_node("ControlBar/EndTurnButton").set_disabled(true)
	
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
		
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")

	get_node("TutorialTooltip").reset()
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.placed(true)
		player_piece.clear_assist()
	get_node("AssistSystem").clear_assist()
	get_node("PhaseShifter").enemy_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	self.state = STATES.enemy_turn
	
func handle_deploy():
	if self.state == self.STATES.deploying:
		emit_signal("deployed")
	
func handle_end_turn_released():
	if get_node("RestartBar").animating_flag:
		lighten(0.2)
		get_node("RestartBar").stop()
	else:
		end_turn()
		
		
func holding_end_turn():
	darken(0.1, 0.8)
	get_node("RestartBar").start()


func restart():
	set_process_input(false)
	set_process(false)
	get_node("/root/AnimationQueue").stop()
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	get_node("/root/DataLogger").log_restart(self.level_schematic.name, self.turn_count)
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level_schematic})


#called to check if a mouse is currently inside the area of a piece
func check_hovered():
	var hovered = get_node("CursorArea").get_piece_hovered()
	if hovered:
		hovered.hovered()


func _input(event):
	computer_input(event)
	

func computer_input(event):
	#select a unit
	if get_node("InputHandler").is_select(event):
		var has_selected = get_node("Grid").selected != null
		var hovered = get_node("CursorArea").get_piece_or_location_hovered()
		if hovered and hovered.is_targetable():

			#if a star is active, handle it appropriately
			if self.has_active_star:
				self.has_active_star = false
				var successful = hovered.star_input_event(event)
				if !successful:
					get_node("ControlBar/StarBar").refund()
			else:
				#if during a tutorial level, make sure move is as intended
				if self.tutorial != null:
					if self.tutorial.move_is_valid(get_turn_count(), hovered.coords):
						hovered.input_event(event, has_selected)
					else:
						print("not valid??")
				else:
					hovered.input_event(event, has_selected)
				
		elif get_node("Grid").selected != null:
			if self.tutorial != null and !self.tutorial.has_forced_action(get_turn_count()):
				get_node("Grid").selected.invalid_move()
				get_node("Grid").deselect()
	
	#don't handle any other input during forced actions
	if self.mid_forced_action:
		return
		
	if get_node("InputHandler").is_deselect(event): 
		if get_node("Grid").selected:
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
			
			set_process_input(false)
			set_process(false)
			yield(get_node("InfoOverlay"), "description_finished")
			set_process_input(true)
			set_process(true)


	elif event.is_action("debug_level_skip") and event.is_pressed():
		if(self.level_schematic.next_level != null):
			set_process(false)
			set_process_input(false)
			if get_node("/root/AnimationQueue").is_animating():
				yield(get_node("/root/AnimationQueue"), "animations_finished")
			get_node("/root/AnimationQueue").stop()
			get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level_schematic.next_level})
			
			
	elif event.is_action("restart") and event.is_pressed():
		restart()
	
	elif event.is_action("toggle_fullscreen") and event.is_pressed():
		if OS.is_window_fullscreen():
			OS.set_window_fullscreen(false)
			OS.set_window_maximized(true)
			var current_size = OS.get_window_size()
			OS.set_window_size(Vector2(670, current_size.y))
		else:
			OS.set_window_fullscreen(true)
			OS.set_window_maximized(false)
			
			
	elif event.is_action("test_action") and event.is_pressed():
		get_node("/root/AnimationQueue").debug()
		debug_mode()
		for enemy_piece in get_tree().get_nodes_in_group("enemy_pieces"):
			enemy_piece.debug()
			
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.debug()
			
	elif event.is_action("test_action2") and event.is_pressed():
		get_node("/root/global").save_state()

		#print(get_node("Grid").pieces)


func _process(delta):
	get_node('FpsLabel').set_text(str(OS.get_frames_per_second()))
	
	if self.state_manager.check_player_win(): 
		player_win()
	elif self.state == STATES.enemy_turn:
		enemy_phase()
		self.state = STATES.transitioning
	elif self.state == STATES.transitioning:
		pass
		
		
func enemy_phase():
	print("in enemy phase???")
	if self.tutorial != null and self.tutorial.has_enemy_turn_start_rule(get_turn_count()):
		self.tutorial.display_enemy_turn_start_rule(get_turn_count())
		set_process_input(false)
		set_process(false)
		yield(self.tutorial, "rule_finished")
		set_process_input(true)
		set_process(true)
	
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	
	enemy_pieces.sort_custom(self, "_sort_by_y_axis") #ensures the pieces in front move first
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_start()
	
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_update()
		
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")
		
	enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_attack_update()

	
	#if there are enemy pieces, wait for them to finish
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")

	
	deploy_wave()
	load_in_next_wave()
	display_wave_preview()
		
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	
	
	get_node("Timer2").set_wait_time(0.5)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	var player_pieces = get_tree().get_nodes_in_group("player_pieces")
	if self.state_manager.check_enemy_win(self.turn_count): #logic would change based on game type
		enemy_win()
	
	if self.tutorial != null and self.tutorial.has_enemy_turn_end_rule(get_turn_count()):
		self.tutorial.display_enemy_turn_end_rule(get_turn_count())
		set_process_input(false)
		set_process(false)
		yield(self.tutorial, "rule_finished")
		set_process_input(true)
		set_process(true)
	
	if self.state != STATES.end:
		get_node("PhaseShifter").player_phase_animation()
		yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
		self.state_manager.update(self.turn_count)
		start_player_phase()



func start_player_phase():
	self.turn_count += 1
	get_node("ControlBar/EndTurnButton").set_disabled(false)
	
	get_node("AssistSystem").reset_combo()
	if self.reinforcements.has(get_turn_count()):
		reinforce()
		yield(self, "reinforced")
	
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.turn_update()
		
	if self.tutorial != null and self.tutorial.has_player_turn_start_rule(get_turn_count()):
		self.tutorial.display_player_turn_start_rule(get_turn_count())
		set_process_input(false)
		set_process(false)

		yield(self.tutorial, "rule_finished")
		set_process(true)
		set_process_input(true)
	
	
	if self.tutorial != null and self.tutorial.has_forced_action(self.turn_count):
		self.mid_forced_action = true
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
	get_node("ShakeCamera").shake(0.6, 30, 12)
	
func small_screen_shake():
	get_node("ShakeCamera").shake(0.4, 24, 5)

func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false


func deploy_wave():
	for coords in self.enemy_reinforcements.keys():
		var piece = self.enemy_reinforcements[coords]
		if get_node("Grid").pieces.has(coords):
			var blocking_piece = get_node("Grid").pieces[coords]
			if blocking_piece.side == "PLAYER":
				blocking_piece.block_summon()
				piece.queue_free()
			else:
				blocking_piece.summon_buff(piece.hp, piece.get_modifiers())
				piece.queue_free()
				
		else:
			get_node("Grid").add_piece(coords, piece, true)
		self.enemy_reinforcements.erase(coords)


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
			self.enemy_reinforcements[coords] = enemy_piece

	
	
func display_wave_preview():
	get_node("Grid").reset_reinforcement_indicators()
	for coords in self.enemy_reinforcements.keys():
		var type = self.enemy_reinforcements[coords].type
		get_node("Grid").locations[coords].set_reinforcement_indicator(type)


func player_win():
	self.state = STATES.end
	set_process(false)
	set_process_input(false)
#	
#	if self.level_schematic.seamless and self.level_schematic.next_level != null:
#		#load_in_next_wave_relative(keystone_coords)
#		get_node("Grid").clear_board()
#		self.level_schematic = self.level_schematic.next_level
#		soft_reset()
#	else:
		
	get_node("/root/AnimationQueue").stop()
	
	get_node("/root/DataLogger").log_win(self.level_schematic.name, self.turn_count)
	
	#saves the progress made, right now just the units unlocked
	get_node("/root/global").save_state()
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	get_node("Timer2").set_wait_time(0.5)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	if self.level_schematic.is_sub_level():
		get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level_schematic.next_level})
	else:
		get_node("/root/global").goto_scene("res://WinScreen.tscn", {"level":self.level_schematic.next_level})
	

func enemy_win():
	self.state = STATES.end
	set_process(false)
	set_process_input(false)
	if self.level_schematic.seamless:
		#get_node("Grid").clear_board()
		#soft_reset()
		#clear enemies
		#readd the first wave
		#self.turn_count = 0
		restart()
	else:
		get_node("/root/AnimationQueue").stop()
		get_node("/root/DataLogger").log_lose(self.level_schematic.name, self.turn_count)
		
		print(get_node("/root/AnimationQueue").is_animating())
		if get_node("/root/AnimationQueue").is_animating():
			yield(get_node("/root/AnimationQueue"), "animations_finished")
		
		get_node("Timer2").set_wait_time(0.5)
		get_node("Timer2").start()
		yield(get_node("Timer2"), "timeout")
		
		get_node("/root/global").goto_scene("res://LoseScreen.tscn", {"level": self.level_schematic})
	

func next_level():
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level_schematic.next_level})

func previous_level():
	print("in previous level")
	print (self.level_schematic.previous_level)
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level_schematic.previous_level})


func damage_defenses():
	print("caught damage defenses")
	enemy_win()
		
func display_overlay(unit_name):
	get_node("/root/AnimationQueue").enqueue(get_node("OverlayDisplayer"), "animate_display_overlay", true, [unit_name])

func darken(time=0.4, amount=0.3):
	get_node("Tween").interpolate_property(get_node("DarkenLayer"), "visibility/opacity", 0, amount, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")

func lighten(time=0.4):
	var amount = get_node("DarkenLayer").get_opacity()
	get_node("Tween").interpolate_property(get_node("DarkenLayer"), "visibility/opacity", amount, 0, time, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")

func handle_invalid_move():
	get_node("SamplePlayer").play("error")
	get_node("InvalidMoveIndicator/AnimationPlayer").play("flash")
		
func handle_assassin_passive(attack_range, caller):
	if self.assassin != null and caller != self.assassin:
		self.assassin.trigger_passive(attack_range)
	
