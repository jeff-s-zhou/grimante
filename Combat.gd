extends Node2D

const STATES = {"player_turn":0, "enemy_turn":1, "transitioning":3, "deploying":4, "instruction":5}

const Berserker = preload("res://PlayerPieces/BerserkerPiece.tscn")

var state = STATES.deploying
var enemy_waves = null

var tutorial = null

var instructions = []
var reinforcements = {}
var turn_count = 0
var level_schematic_func = null
var level_schematic = null

var state_manager = null

onready var Constants = get_node("/root/constants")

var next_wave #the wave that was used for reinforcement indication

var tabbed_flag #to check if a current description is tabbed in

signal wave_deployed
signal next_pressed
signal reinforced
signal done_initializing

signal deployed

signal animation_done

var assassin = null


func _ready():
	
	get_node("Timer").set_active(false)
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Grid").set_pos(Vector2(73, 270))
	#get_node("Grid").set_pos(Vector2(400, 250))
	debug_mode()
	
	get_node("ControlBar/EndTurnButton").connect("released", self, "handle_end_turn_released")
	get_node("ControlBar/EndTurnButton").connect("holding", self, "holding_end_turn")
	
	get_node("RestartBar").connect("bar_filled", self, "restart")
	
	get_node("/root/AnimationQueue").connect("animation_count_update", self, "update_animation_count_display")
	
	get_node("TutorialPopup").set_pos(Vector2((get_viewport_rect().size.width)/2, -100))
	get_node("AssistSystem").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height - 100))

	get_node("/root/AnimationQueue").reset_animation_count()
#	
#	
#
#	self.level_schematic_func = get_node("/root/global").get_param("level")
#	self.level_schematic = self.level_schematic_func.call_func()

	self.level_schematic = get_node("/root/global").get_param("level")
	if self.level_schematic.tutorial != null:
		var tutorial_func = self.level_schematic.tutorial
		self.tutorial = tutorial_func.call_func()
		if self.tutorial != null:
			add_child(self.tutorial)

	self.enemy_waves = self.level_schematic.enemies

	self.reinforcements = self.level_schematic.reinforcements
	
	
	#we store the initial wave count as the first value in the array

	if self.level_schematic.end_conditions.has(constants.end_conditions.Timed):
		self.state_manager = load("res://UI/TimedSystem.tscn").instance()
	else:
		self.state_manager= load("res://UI/ClearRoomSystem.tscn").instance()

	add_child(self.state_manager)
	self.state_manager.initialize(self.level_schematic, get_node("ControlBar/StarButton"), self.level_schematic.flags)
	
	if self.level_schematic.flags.has("no_stars"):
		get_node("ControlBar/StarButton").disable()

	if self.level_schematic.shadow_wall_tiles.size() > 0:
		get_node("Grid").initialize_shadow_wall_tiles(self.level_schematic.shadow_wall_tiles)
	
	if self.level_schematic.shifting_sands_tiles.size() > 0:
		get_node("Grid").initialize_shifting_sands_tiles(self.level_schematic.shifting_sands_tiles)	

	for key in self.level_schematic.required_units.keys():
		initialize_piece(self.level_schematic.required_units[key], false, key)
	
	get_node("Grid").update_furthest_back_coords()
	
	deploy_wave(true)
	
	set_process(true)
	set_process_input(true)	
		
	if self.level_schematic.free_deploy:
		get_node("Grid").set_deploying(true, self.level_schematic.deploy_tiles)
		
		
#		for name in get_node("/root/global").available_unit_roster:
#			if name == "Berserker":
#				initialize_piece(Berserker, true)
#		for unit in self.level_schematic.allies:
#			initialize_piece(unit, true)
		
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.start_deploy_phase()

		if (self.instructions.size() > 0):
			handle_instructions()
			yield(self, "next_pressed")
		
		yield(self, "deployed")
		get_node("Grid").set_deploying(false)
		for player_piece in get_tree().get_nodes_in_group("player_pieces"):
			player_piece.deploy()
	
	
	get_node("Timer2").set_wait_time(0.3)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	
	get_node("PhaseShifter").player_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	
	get_node("ControlBar").show()
	
	start_player_phase()
	
	
func get_turn_count():
	return self.turn_count
#	
#
func update_animation_count_display(count):
	get_node("AnimationCountLabel").set_text(str(count))
	
	
func is_within_deploy_range(coords):
	return coords in self.level_schematic.deploy_tiles

func debug_mode():
	get_node("Grid").debug()

func soft_copy_dict(source, target):
    for k in source.keys():
        target[k] = source[k]

func soft_copy_array(source, target):
	for item in source:
		target.push_back(item)
		

func initialize_piece(piece, on_bar=false, key=null):
	var new_piece = piece.instance()
	if new_piece.UNIT_TYPE == "Assassin":
		self.assassin = new_piece
	new_piece.set_opacity(0)
	new_piece.connect("invalid_move", self, "handle_invalid_move")
	new_piece.connect("shake", self, "screen_shake")
	if self.tutorial != null:
		new_piece.connect("animated_placed", self, "handle_piece_placed")
	
	if on_bar:
		get_node("Grid").add_piece_on_bar(new_piece)
	else:
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
	

func handle_piece_placed():
	if self.tutorial.has_forced_action_result():
		set_process_input(false)
		self.tutorial.handle_forced_action_result()
		yield(self.tutorial, "rule_finished")
		set_process_input(true)
		self.tutorial.display_forced_action(self.turn_count)
	
	#shouldn't interfere with any other forced actions, since it'll only end when all pieces are placed
	if !get_node("ControlBar/StarButton").has_star():
		#check if we can automatically end turn
		var player_pieces = get_tree().get_nodes_in_group("player_pieces")
		for player_piece in player_pieces:
			if !player_piece.is_placed():
				return
		end_turn()

#	
#
func initialize_enemy_piece(key, prototype, health, modifiers, mass_summon, animation_sequence=null):
	var position
	if typeof(key) == TYPE_INT:
		position = get_node("Grid").get_top_of_column(key)
	else:
		position = key #that way when we need to we can specify by coordinates
		
	#if the spawn point is occupied, can't summon
	if(get_node("Grid").pieces.has(position)):
		var occupant = get_node("Grid").pieces[position]
		if occupant.side == "PLAYER":
			occupant.block_summon()
		elif occupant.side == "ENEMY":
			occupant.summon_buff(health, modifiers)
	elif !get_node("Grid").is_offsides(position):
		var enemy_piece = prototype.instance()
		get_node("Grid").add_piece(position, enemy_piece)
		enemy_piece.initialize(health, modifiers, prototype)
		enemy_piece.connect("broke_defenses", self, "damage_defenses")
		enemy_piece.connect("enemy_death", self.state_manager.get_node("StarSubsystem"), "add_kill_count")
		#enemy_piece.get_node("Sprinkles").set_particle_endpoint(get_node("ComboSystem/ComboPointsLabel").get_global_pos())
		enemy_piece.check_global_seen()
		if animation_sequence != null:
			animation_sequence.add(enemy_piece, "animate_summon", false)
		else:
			enemy_piece.add_animation(enemy_piece, "animate_summon", false)
			

func end_turn():
	self.state = STATES.transitioning
	
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
	
func handle_end_turn_released():
	if get_node("RestartBar").animating_flag:
		lighten(0.2)
		get_node("RestartBar").stop()
	else:
		if self.state == self.STATES.deploying:
			emit_signal("deployed")
		if self.state == self.STATES.player_turn:
			end_turn()
		
		
func holding_end_turn():
	darken(0.1, 0.8)
	get_node("RestartBar").start()


func restart():
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level_schematic})

	

func _input(event):
	computer_input(event)

func computer_input(event):
	#select a unit
	if get_node("InputHandler").is_select(event):
		var hovered = get_node("CursorArea").get_piece_or_location_hovered()
		if hovered:
			#if during a tutorial level, make sure move is as intended
			if self.tutorial != null:
				if self.tutorial.move_is_valid(get_turn_count(), hovered.coords):
					hovered.input_event(event)
			else:
				hovered.input_event(event)
				
		elif get_node("Grid").selected != null:
			get_node("Grid").selected.invalid_move()
	
	#deselect a unit
	if get_node("InputHandler").is_deselect(event): 
		if get_node("Grid").selected:
			get_node("Grid").deselect()
	
	elif get_node("InputHandler").is_ui_accept(event):
		if self.state == self.STATES.deploying:
			emit_signal("deployed")
		if self.state == self.STATES.player_turn:
			end_turn()
			
	elif event.is_action("detailed_description") :
		if event.is_pressed() and !event.is_echo():
			var hovered_piece = get_node("CursorArea").get_piece_hovered()
			if hovered_piece == null:
				return
			
			elif hovered_piece.side == "ENEMY":
				hovered_piece.set_seen(true)
				get_node("InfoOverlay").display_enemy_info(hovered_piece)
			else: #elif hovered_piece.side == "PLAYER"
				hovered_piece.set_seen(true)
				get_node("InfoOverlay").display_player_info(hovered_piece)


		elif !event.is_pressed() and !event.is_echo():
			get_node("InfoOverlay").hide()


	elif event.is_action("debug_level_skip") and event.is_pressed():
		if(self.level_schematic.next_level != null):
			if get_node("/root/AnimationQueue").is_animating():
				yield(get_node("/root/AnimationQueue"), "animations_finished")
			get_node("/root/global").goto_scene("res://Combat.tscn", {"level": self.level_schematic.next_level})
			
			
	elif event.is_action("restart") and event.is_pressed():
		restart()
	
	elif event.is_action("toggle_fullscreen") and event.is_pressed():
		if OS.is_window_fullscreen():
			OS.set_window_fullscreen(false)
			OS.set_window_maximized(true)
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
	var enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	
	enemy_pieces.sort_custom(self, "_sort_by_y_axis") #ensures the pieces in front move first
	for enemy_piece in enemy_pieces:
		enemy_piece.aura_update()
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_update()
	
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")
		
	enemy_pieces = get_tree().get_nodes_in_group("enemy_pieces")
	for enemy_piece in enemy_pieces:
		enemy_piece.turn_attack_update()
		
	get_node("Grid").update_furthest_back_coords()
	
	#if there are enemy pieces, wait for them to finish
	if(get_node("/root/AnimationQueue").is_animating()):
		yield(get_node("/root/AnimationQueue"), "animations_finished")

	
	deploy_wave()
		
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
		yield(self.tutorial, "rule_finished")
		set_process_input(true)
	
	get_node("PhaseShifter").player_phase_animation()
	yield( get_node("PhaseShifter/AnimationPlayer"), "finished" )
	self.state_manager.update(self.turn_count)
	start_player_phase()



func start_player_phase():
	self.turn_count += 1
	
	if self.tutorial != null and self.tutorial.has_player_turn_start_rule(get_turn_count()):
		self.tutorial.display_player_turn_start_rule(get_turn_count())
		set_process_input(false)
		yield(self.tutorial, "rule_finished")
		set_process_input(true)
	
	
	if self.tutorial != null:
		self.tutorial.display_forced_action(get_turn_count())
	
	get_node("AssistSystem").reset_combo()
	if self.reinforcements.has(get_turn_count()):
		reinforce()
		yield(self, "reinforced")
	if (self.instructions.size() > 0):
		handle_instructions()
		yield(self, "next_pressed")
	
	for player_piece in get_tree().get_nodes_in_group("player_pieces"):
		player_piece.turn_update()

	self.state = STATES.player_turn


func reinforce():
	var reinforcement_wave = self.reinforcements[get_turn_count()]
	for key in reinforcement_wave.keys():
		var prototype = reinforcement_wave[key]
		initialize_piece(prototype, false, key)
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
	
	get_node("Tween").interpolate_property(popup, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	
	var end_pos = popup.get_pos() + Vector2(0, get_viewport_rect().size.height/2 + 100)
	get_node("Tween").interpolate_property(popup, "transform/pos",popup.get_pos(), end_pos, 0.7, Tween.TRANS_BACK, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	popup.transition_in()
	yield(popup, "done")
	
	yield(popup, "next")
	popup.transition_out()
	get_node("Tween").interpolate_property(popup, "visibility/opacity", 1, 0, 0.7, Tween.TRANS_SINE, Tween.EASE_IN)
	
	var end_pos = Vector2((get_viewport_rect().size.width)/2, -100)
	get_node("Tween").interpolate_property(popup, "transform/pos", popup.get_pos(), end_pos, 0.7, Tween.TRANS_BACK, Tween.EASE_IN)
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
	get_node("ShakeCamera").shake(0.5, 35, 10)


func _sort_by_y_axis(enemy_piece1, enemy_piece2):
		if enemy_piece1.coords.y > enemy_piece2.coords.y:
			return true
		return false


func deploy_wave(mass_summon=false):
	
	#check if cleared for multitimed system
	#self.state_manager.pre_deploy_wave_check()

	#var wave = self.next_wave
	#self.next_wave = self.enemy_waves.get_next_summon()
	var wave = self.enemy_waves.get_next_summon(self.turn_count)
	
	if wave != null:
		for key in wave.keys():
			var prototype_parts = wave[key]
			var prototype = prototype_parts["prototype"]
			var hp = prototype_parts["hp"]
			var modifiers = prototype_parts["modifiers"]
			initialize_enemy_piece(key, prototype, hp, modifiers, mass_summon)

	display_wave_preview(self.enemy_waves.preview_next_summon(self.turn_count))


func display_wave_preview(wave):
	get_node("Grid").reset_reinforcement_indicators()
	if wave != null:
		for key in wave.keys():
			var position = null
			if typeof(key) == TYPE_INT:
				position = get_node("Grid").get_top_of_column(key)
			else:
				position = key #that way when we need to we can specify by coordinates
			get_node("Grid").locations[position].set_reinforcement_indicator(true)


func player_win():
	set_process(false)
	self.state = STATES.transitioning
	if get_node("/root/AnimationQueue").is_animating():
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	get_node("Timer2").set_wait_time(0.5)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	get_node("/root/global").goto_scene("res://WinScreen.tscn", {"level":self.level_schematic.next_level})


func enemy_win():
	set_process(false)
	self.state = STATES.transitioning
	print(get_node("/root/AnimationQueue").is_animating())
	if get_node("/root/AnimationQueue").is_animating():
		print("yielded in enemy win")
		yield(get_node("/root/AnimationQueue"), "animations_finished")
	print("not waiting here")
	get_node("Timer2").set_wait_time(0.5)
	get_node("Timer2").start()
	yield(get_node("Timer2"), "timeout")
	get_node("/root/global").goto_scene("res://LoseScreen.tscn", {"level": self.level_schematic})
	
	
func damage_defenses():
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
		
func handle_assassin_passive(attack_range):
	if self.assassin != null:
		self.assassin.trigger_passive(attack_range)
	
