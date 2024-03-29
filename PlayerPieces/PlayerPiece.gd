extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var States = {"LOCKED":0, "DEFAULT":1, "CLICKED": 2, "PLACED":3, "SELECTED":4, "DEAD":5}

onready var AssistSystem = get_node("/root/AssistSystem")

const flyover_prototype = preload("res://EnemyPieces/Components/Flyover.tscn")

var explosion_prototype = preload("res://PlayerPieces/Components/Explosion.tscn")

onready var ASSIST_TYPES = AssistSystem.ASSIST_TYPES

var assist_type = null

var descriptions = []

var state = States.PLACED
var cursor_area

var hovered_flag = false #has to be set to true in order to select

var cooldown = 0

var assist_flag = false

var diagonal_guide_prediction_flag = false

var movement_value = 1 setget , get_movement_value
var attack_bonus = 0

const SHOVE_SPEED = 4

signal invalid_move

signal pre_attack(attack_coords)

signal stepped_move_completed

signal targeted

signal animated_placed(hero_name)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("CollisionArea").connect("mouse_enter", self, "hovered")
	get_node("CollisionArea").connect("mouse_exit", self, "unhovered")
#	connect("mouse_enter", self, "hovered")
#	connect("mouse_exit", self, "unhovered")

	self.side = "PLAYER"
	

func load_description(unit_name):
	var file_name = unit_name.to_lower() + ".description"
	var save = File.new()
	if !save.file_exists("res://LongText/" + file_name):
		return #Error!  We don't have a save to load

	# Load the file line by line
	save.open("res://LongText/" + file_name, File.READ)
	
	while (!save.eof_reached()):
		var line = save.get_line()
		if line == "\n" or line == "":
			continue
		var line_parts = line.split("/")
		var type = line_parts[0]
		var name = line_parts[1]
		var text = line_parts[2]
		
		self.descriptions.append({"type":type, "name":name, "text":text})
	save.close()
	
	
func add_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(1)
	set_targetable(false) #so we don't have targeting shenanigans mid animation
	self.debug_anim_counter += 1
	self.mid_animation = true
	
func subtract_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(-1)
	self.debug_anim_counter -=1
	if self.debug_anim_counter == 0:
		if self.state != States.DEAD: #dead units can't be targeted
			set_targetable(true)
	self.mid_animation = false
	
func darken(time, amount=0.3):
	get_node("/root/Combat").darken(time, amount)
	
func lighten(time):
	get_node("/root/Combat").lighten(time)
	
	
func set_shield(flag, delay=0.0):
	if self.shielded != flag:
		self.shielded = flag
		add_animation(self, "animate_set_shield", false, [flag, delay])


func animate_set_shield(flag, delay=0.0):
	if delay > 0.0:
		get_node("Timer").set_wait_time(delay)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
	if flag:
		#TODO: play a sound here
		get_node("Physicals/HeroShield").display()
	else:
		get_node("SamplePlayer").play("window glass break smash 3")
		get_node("Physicals/HeroShield").animate_explode()


func get_assist_bonus_attack():
	return self.AssistSystem.get_bonus_attack(self)


#call this function right before being assisted
func handle_pre_assisted():
	self.AssistSystem.assist(self)
	if self.AssistSystem.get_bonus_invulnerable(self):
		set_shield(true)

#called from Actions
func trigger_assist_flag():
	print("triggering assist flag")
	self.assist_flag = true


func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
		#we specifically redirect it through the AssistSystem to check if it's disabled
		self.AssistSystem.activate_assist(self.assist_type, self)
	else:
		self.AssistSystem.clear_assist()


#start emitting the particles
func activate_assist(assist_type):
	add_animation(get_node("Physicals/InspireIndicator"), "animate_inspire_ready", true, [assist_type])
	
func assist(piece, assist_type):
	add_animation(get_node("Physicals/InspireIndicator"), "animate_give_inspire", true, [assist_type, piece])
	add_animation(piece.get_node("Physicals/InspireIndicator"), "animate_receive_inspire", true, [assist_type])

	
func clear_assist():
	add_animation(get_node("Physicals/InspireIndicator"), "animate_clear_inspire", false)


func get_movement_value():
	var adjacent_range = get_parent().get_range(self.coords, [1, 2], "ENEMY")
	for coords in adjacent_range:
		if get_parent().pieces[coords].is_slime():
			return self.AssistSystem.get_bonus_movement(self) + 1
	return self.AssistSystem.get_bonus_movement(self) + movement_value


func star_reactivate():
	self.state = States.DEFAULT
	add_animation(self, "animate_reactivate", false, [true])
	if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
		self.hovered()


#called once the unit positions are finalized in the deployment phase
func deploy():
	self.deploying_flag = false
	self.state = States.PLACED
	
func block_summon():
	attacked()

	
func set_cooldown(cooldown):
	self.cooldown = cooldown + 1 #offset for the first countdown tick
	
func get_ally_shove_range():
	return get_parent().get_range(self.coords, [1, 2], "PLAYER")
	
func _is_within_ally_shove_range(coords):
	return coords in get_ally_shove_range()
	
	
func is_placed():
	return self.state == States.PLACED
	
func walk_off(coords_distance, exits_bottom=true):
	add_animation(self, "animate_walk_off", true, [coords_distance])
	get_node("CollisionArea").set_pickable(false)
	self.state = States.DEAD
	self.grid.remove_piece(self.coords)
	add_to_group("dead_heroes")
	remove_from_group("player_pieces")

#add own version to not delete self lol
func animate_walk_off(coords_distance):
	add_anim_count()
	get_node("/root/SteamHandler").set_what_do()
	get_node("CollisionArea").set_global_pos(Vector2(-100, -100))
	var speed = 300
	var distance = get_parent().get_real_distance(coords_distance)
	var time = distance.length()/speed
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), get_pos() + distance, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 1, 0, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	animate_short_hop_to_pos(speed, distance.length())
	yield(get_node("Tween"), "tween_complete")
	#need this in because apparently Tween emits the signal slightly early
	get_node("Timer").set_wait_time(0.1)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	subtract_anim_count()


func delete_self(isolated_call=true, delay=0.0):
	get_node("CollisionArea").set_pickable(false)
	#get_node("CollisionArea").set_monitorable(false)
	add_to_group("dead_heroes")
	add_animation(self, "animate_delete_self", false, [delay])
	self.state = States.DEAD
	get_parent().remove_piece(self.coords)
	remove_from_group("player_pieces")


func animate_delete_self(delay=0.0):
	add_anim_count()
	set_z(-9)
	if delay > 0.0:
		get_node("Timer").set_wait_time(delay)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
	get_node("SamplePlayer").play("rocket glass explosion 5")
	get_node("Physicals").set_opacity(0)
	get_node("Shadow").set_opacity(0)
	emit_signal("shake")
	var explosion = self.explosion_prototype.instance()
	add_child(explosion)
	explosion.set_emit_timeout(0.3)
	explosion.set_emitting(true)
	get_node("Timer").set_wait_time(0.5)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	#hacky ass shit. Can't disable, because then on revive you can't select it
	#can't move the whole pos out of the way, because then on using the revive selector,
	#switching to another piece causes the sprite to disappear entirely somehow
	get_node("CollisionArea").set_global_pos(Vector2(-100, -100))
	explosion.queue_free()
	subtract_anim_count()


func queue_free():
	if is_in_group("player_pieces"):
		remove_from_group("player_pieces")
	.queue_free()

func resurrect(coords):
	self.coords = coords
	var pos = self.grid.locations[coords].get_pos()
	set_pos(pos)
	get_node("CollisionArea").set_pos(Vector2(0, -6))
	add_to_group("player_pieces")
	remove_from_group("dead_heroes")
	set_z(0)
	get_parent().add_piece(self.coords, self, true)
	add_animation(self, "animate_resurrect", true)
	get_node("CollisionArea").set_pickable(true)
	#get_node("CollisionArea").set_monitorable(true)
	self.state = States.DEFAULT


func animate_resurrect(blocking=true):
	set_pos(get_parent().locations[self.coords].get_pos())
	add_anim_count()
	get_node("SamplePlayer").play("revive2")
	
	get_node("AnimationPlayer").stop()
	get_node("Physicals").set_opacity(1)
	get_node("Physicals/AnimatedSprite").set_opacity(1)
	get_node("Physicals/CooldownSprite").hide()
	
	var light2d = get_node("Physicals/Light2D")
	light2d.set_enabled(true)
	light2d.set_energy(15)
	
	get_node("Physicals").set_opacity(1)
	var tween = Tween.new()
	add_child(tween)
	
	tween.interpolate_property(get_node("Shadow"), "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(light2d, "energy", 15, 0.01, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	yield(tween, "tween_complete")
	yield(tween, "tween_complete")
	light2d.set_enabled(false)
	tween.queue_free()
	if blocking:
		emit_signal("animation_done")
	subtract_anim_count() #will set targetable to true, since state is no longer DEAD
	if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
		self.hovered()
#		
		
func animate_possible_revive():
	print("animating possible revive for:", self.unit_name)
	print("opacity before: ", get_node("Physicals/AnimatedSprite").get_opacity())
	get_node("Physicals/AnimatedSprite").set_opacity(1)
	print("opacity after: ", get_node("Physicals/AnimatedSprite").get_opacity())
	get_node("CollisionArea").set_pos(Vector2(0, -6))
	get_node("AnimationPlayer").play("possible_revive")


func animate_summon():
	add_anim_count()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	subtract_anim_count()

	

func initialize(cursor_area, flags):
	self.cursor_area = cursor_area
	add_to_group("player_pieces")
	if flags.has("no_inspire"):
		pass
	else:
		get_node("Physicals/InspirePiece").initialize(self.assist_type)


func is_inspire_enabled():
	pass


func added_to_grid():
	pass
	
func animate_reactivate(star_reactivate=false):
	get_node("Physicals/CooldownSprite").show()
	if star_reactivate:
		get_node("SamplePlayer").play("star_reactivate")
	#get_node("Physicals/AnimatedSprite").set_opacity(0)
	var sprite = get_node("Physicals/AnimatedSprite")
	var glow_sprite = get_node("Physicals/GlowSprite")
	
	var start_opacity = sprite.get_opacity()
	get_node("Tween").interpolate_property(sprite, "visibility/opacity", start_opacity, 1, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_property(glow_sprite, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_QUART, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Physicals/CooldownSprite").hide()
	yield(get_node("Tween"), "tween_complete")
	get_node("Tween").interpolate_property(glow_sprite, "visibility/opacity", 1, 0, 0.7, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	get_node("Tween").start()


func turn_update():
	set_z(0)
	self.state = States.DEFAULT
	add_animation(self, "animate_reactivate", false)
	if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
		self.hovered()


func set_coords(new_coords):
	get_parent().move_piece(self.coords, new_coords)
	self.coords = new_coords


#ANIMATION FUNCTIONS


#move from tile to tile
func animate_stepped_move(old_coords, new_coords, pathed_range, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	add_anim_count()
	var path = []
	var current_pathed_coords = pathed_range[new_coords]
	while(current_pathed_coords.coords != old_coords):
		path.push_front(current_pathed_coords.coords)
		current_pathed_coords = current_pathed_coords.previous
	
	var previous_coords = old_coords
	
	for coords in path:
		var location = get_parent().locations[coords]
		var new_position = location.get_pos()
		
		animate_short_hop(speed, coords)
		animate_move_to_pos(new_position, speed, trans_type, ease_type)
		previous_coords = coords
		yield(get_node("Tween"), "tween_complete")
		get_node("Timer").set_wait_time(0.1)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")

	if blocking:
		emit_signal("animation_done")
	subtract_anim_count()


	
func attack_highlight():
	pass
	
func movement_highlight():
	get_node("Physicals/OverlayLayers/Green").show()
	
func assist_highlight():
	get_node("Physicals/OverlayLayers/Green").show()


#called when the whole board's highlighting is reset
func clear_display_state():
	self.hovered_flag = false
	get_node("Physicals/OverlayLayers/White").hide()
	get_node("Physicals/OverlayLayers/Green").hide()
	if(self.state != States.PLACED):
		get_node("Physicals/AnimatedSprite").play("default")


func reset_prediction_highlight():
	pass
	#get_node("Physicals/Physicals/AnimatedSprite").show()
	#get_node("Physicals/PredictionLayer").hide()
	

#called on mouse entering the CollisionArea
func hover_highlight():
	if(self.state != States.PLACED):
		#get_node("SamplePlayer").play("tile_hover")
		get_node("Physicals/OverlayLayers/White").show()
	else:
		pass


#called on mouse exiting the CollisionArea
func unhovered():
	if self.state != States.DEAD:
		self.hovered_flag = false
		get_node("Physicals/OverlayLayers/White").hide()
		self.grid.reset_prediction()
		if get_parent().selected == null:
			#print(get_name() + " is calling clearing display state in unhovered" )
			get_parent().clear_display_state()



#called when hovered over during player turn		
func hovered():
	if self.state != States.DEAD:
		#you need this lol, otherwise moving from one piece to another real fast fucks everything up
		get_node("Timer").set_wait_time(0.01) 
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
		self.hovered_flag = true
		if !self.mid_animation:
			hover_highlight()
		
		if get_parent().selected == null and self.state != States.PLACED:
			get_parent().temp_remove_piece(self.coords)
			display_action_range()
			get_parent().temp_add_piece(self.coords, self)
		
		#might break things
		elif get_parent().selected != null and get_parent().selected != self:
			self.grid.predict(self.coords)
		

func star_input_event(event):
	if self.state == States.PLACED:
		star_reactivate() #reactivate this piece for finishing
		return true
	else:
		return false

#called when an event happens inside the click area hitput
func input_event(event, has_selected):
	if self.state != States.DEAD and self.hovered_flag:
		if self.state == States.CLICKED: #if already selected and clicking oneself again
			get_parent().deselect()
			get_node("/root/Combat").display_description(self)
		
		elif self.deploying_flag: #if in deploy phase
			deploy_input_event(event, has_selected)
			return
	
		elif !has_selected and self.state != States.PLACED:
			select()
	
		else: #if not selected and not self, then some piece is trying to act on this one
			get_parent().set_target(self)


func deploy_input_event(event, has_selected):
	if !has_selected:
		select()
	else:
		get_parent().set_target(self)


func select():
	get_parent().set_selected(self)
	get_node("SamplePlayer").play("mouseover")
	add_animation(self, "animate_glow", false)
	self.state = States.CLICKED
	get_node("SelectedGlow").show()


func deselect(acting=false):
	self.state = States.DEFAULT
	if !acting: #if acting, we unglow the piece after its animation is done or from invalid move
		add_animation(self, "animate_unglow", false)
	get_node("SelectedGlow").hide()
	
	
func animate_glow():
	get_node("AnimationPlayer").play("glow")
	
func animate_unglow():
	get_node("AnimationPlayer").stop()
	var glow_sprite = get_node("Physicals/GlowSprite")
	var current_opacity = glow_sprite.get_opacity()
	get_node("Tween").interpolate_property(glow_sprite, "visibility/opacity", current_opacity, 0, 0.2, Tween.TRANS_QUART, Tween.EASE_IN)
	get_node("Tween").start()


func select_action_target(target):
	get_parent().deselect(true)
#	self.state = States.DEFAULT
#	get_node("SelectedGlow").hide()
	if self.deploying_flag:
		deploy_select_action_target(target)
	else:
		act(target.coords)


func start_deploy_phase():
	self.state = States.DEFAULT
	self.deploying_flag = true

	
func _is_within_deploy_range(coords):
	return get_parent().is_within_deploy_range(coords)
	
	
func deploy_select_action_target(target):
	if _is_within_deploy_range(target.coords):
		add_animation(self, "animate_unglow", false)
		if get_parent().has_piece(target.coords) and target.side == "PLAYER":
			swap_coords_and_pos(target)
			get_parent().deselect()
		else:
			set_coords(target.coords)
			set_global_pos(target.get_global_pos())
			get_parent().deselect()

	else:
		invalid_move()
		
func swap_coords_and_pos(target):
	get_parent().swap_pieces(self.coords, target.coords)
	var temp_coords = self.coords
	self.coords = target.coords
	target.coords = temp_coords
	
	#set the positions
	set_global_pos(get_parent().get_location(self.coords).get_global_pos())
	target.set_global_pos(get_parent().get_location(target.coords).get_global_pos())
	

#helper function for act
func invalid_move():
	#get_parent().deselect()
	add_animation(self, "animate_unglow", false)
	emit_signal("invalid_move")


#helper function for act
func placed(ending_turn=false):
	if self.state != States.PLACED:
		add_animation(self, "animate_placed", false, [ending_turn])
	get_node("SelectedGlow").hide()
	self.state = States.PLACED
	self.attack_bonus = 0
	self.movement_value = self.DEFAULT_MOVEMENT_VALUE
	
	if ending_turn:
		clear_assist()
	else:
		#can't be in set_coords because stormdancer for example needs to set_coords before executing swap attacks
		self.grid.handle_field_of_lights(self) 
		handle_assist()


func animate_placed(ending_turn=false):
	animate_unglow()
	get_node("Physicals/CooldownSprite").show()
	var sprite = get_node("Physicals/AnimatedSprite")
	get_node("Tween").interpolate_property(sprite, "visibility/opacity", 1, 0, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	#if we're calling it from end_turn() in combat, don't trigger all the individual placed checks
	if !ending_turn:
		emit_signal("animated_placed")


func is_deadly():
	return false

func attacked(attacker=null):
	if !self.shielded:
		delete_self()
		return true
	else:
		set_shield(false)
		return false

func enemy_attacked(delay=0.0):
	if !self.shielded:
		delete_self(true, delay)
		return true
	else:
		set_shield(false, delay)
		return false

func handle_nonlethal_shove(shover):
	pass



func get_sprite():
	return get_node("Physicals/AnimatedSprite").get_sprite_frames().get_frame("default", 0)
	
func is_enemy():
	return false


#OVERRIDEN OR INHERITED FUNCTIONS
func act(new_coords):
	return false

func display_action_range():
	pass
#	for coords in get_ally_shove_range():
#		get_parent().get_at_location(coords).assist_highlight()


