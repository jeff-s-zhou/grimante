extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var States = {"LOCKED":0, "DEFAULT":1, "CLICKED": 2, "PLACED":3, "SELECTED":4, "DEAD":5}

onready var AssistSystem = get_node("/root/Combat/AssistSystem")

const flyover_prototype = preload("res://EnemyPieces/Components/Flyover.tscn")

var explosion_prototype = preload("res://PlayerPieces/Components/Explosion.tscn")

onready var ASSIST_TYPES = AssistSystem.ASSIST_TYPES

var assist_type = null

var direct_attack_description = []
var indirect_attack_description = []
var passive_description = []

var state = States.PLACED
var cursor_area

var cooldown = 0

var assist_flag = false

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
		var description = line_parts[2]
		if type == "Direct":
			#todo, change this so maybe it's saved as a tuple
			self.direct_attack_description.append(name + ". " + description)
		elif type == "Indirect":
			self.indirect_attack_description.append(name + ". " + description)
		elif type == "Passive":
			self.passive_description.append(name + ". " + description)
	save.close()
	
	
func add_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(1)
	get_node("CollisionArea").set_pickable(false) #so we don't have targeting shenanigans mid animation
	self.debug_anim_counter += 1
	self.mid_animation = true
	
func subtract_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(-1)
	self.debug_anim_counter -=1
	if self.debug_anim_counter == 0:
		get_node("CollisionArea").set_pickable(true)
	self.mid_animation = false
	
func darken(time, amount=0.3):
	get_node("/root/Combat").darken(time, amount)
	
func lighten(time):
	get_node("/root/Combat").lighten(time)
	
	
func set_shield(flag):
	if self.shielded != flag:
		self.shielded = flag
		print("calling the set shield animation here?")
		add_animation(self, "animate_set_shield", false, [flag])


func animate_set_shield(flag):
	if flag:
		#TODO: play a sound here
		get_node("Physicals/HeroShield").display()
	else:
		get_node("SamplePlayer").play("window glass break smash 2")
		get_node("Physicals/HeroShield").animate_explode()


func get_assist_bonus_attack():
	return self.AssistSystem.get_bonus_attack()


#call this function right before being assisted
func handle_pre_assisted():
	self.AssistSystem.assist(self)
	if self.AssistSystem.get_bonus_invulnerable():
		print("setting shield in pre-assisted")
		set_shield(true)

	
func trigger_assist_flag():
	self.assist_flag = true


func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
		#we specifically redirect it through the AssistSystem to call the function below in case it's an ultimate
		self.AssistSystem.activate_assist(self.assist_type, self)
	else:
		self.AssistSystem.clear_assist()


#start emitting the particles
func activate_assist(assist_type):
	add_animation(get_node("Physicals/ComboSparkleManager"), "animate_activate_assist", false, [assist_type])
	add_animation(get_node("InspireIndicator"), "animate_inspire_ready", true, [assist_type])
	
func assist(piece, assist_type):
	add_animation(get_node("InspireIndicator"), "animate_give_inspire", true, [assist_type])
	add_animation(self, "animate_assist", false, [piece, assist_type])
	add_animation(piece.get_node("InspireIndicator"), "animate_receive_inspire", true, [assist_type])


#direct the particles to a certain coords
func animate_assist(piece, assist_type):
	var pos_difference = piece.get_pos() - get_pos()
	get_node("Physicals/ComboSparkleManager").animate_assist(assist_type, pos_difference)
	yield(get_node("Physicals/ComboSparkleManager"), "animation_done")

	
func clear_assist():
	add_animation(get_node("Physicals/ComboSparkleManager"), "animate_clear_assist", false, [self.assist_type])
	add_animation(get_node("InspireIndicator"), "animate_clear_inspire", false)


func get_movement_value():
	var adjacent_range = get_parent().get_range(self.coords, [1, 2], "ENEMY")
	for coords in adjacent_range:
		if get_parent().pieces[coords].is_slime():
			return self.AssistSystem.get_bonus_movement() + 1
	return self.AssistSystem.get_bonus_movement() + movement_value
	
	
func star_reactivate():
	var player_pieces = get_tree().get_nodes_in_group("player_pieces")
	self.state = States.DEFAULT
	add_animation(self, "animate_reactivate", false)
	if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
		print("hovering???")
		self.hovered()


#called once the unit positions are finalized in the deployment phase
func deploy():
	self.deploying_flag = false
	self.state = States.PLACED
	var seen_range = get_parent().get_range(self.coords, [1, 2], "ENEMY")
	for coords in seen_range:
		if get_parent().pieces[coords].cloaked:
			get_parent().pieces[coords].set_cloaked(false)
	
func block_summon():
	if !self.shielded:
		delete_self()
	else:
		print("setting shield in block summon")
		set_shield(false)

	
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
	self.grid.remove_piece(self.coords)
	remove_from_group("player_pieces")
	
func delete_self(isolated_call=true):
	var location = get_parent().locations[self.coords]
	location.add_corpse(self)
	get_node("CollisionArea").set_pickable(false)
	get_node("CollisionArea").set_monitorable(false)

	add_animation(self, "animate_delete_self", false)
	add_animation(location, "animate_add_corpse", false)
	self.state = States.DEAD
	set_z(-9)
	get_parent().remove_piece(self.coords)
	remove_from_group("player_pieces")


func animate_delete_self():
	add_anim_count()
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
	#emit_signal("animation_done")
	subtract_anim_count()
	get_node("Timer").set_wait_time(3)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")


func queue_free():
	if is_in_group("player_pieces"):
		remove_from_group("player_pieces")
	.queue_free()

func manual_free_cleanup():
	pass

func resurrect():
	print("resurrecting")
	add_to_group("player_pieces")
	set_z(0)
	get_parent().add_piece(self.coords, self, true)
	var location = get_parent().locations[self.coords]
	add_animation(location, "animate_hide_corpse", false)
	add_animation(self, "animate_resurrect", true)
	star_reactivate()


func animate_resurrect(blocking=true):
	get_node("CollisionArea").set_monitorable(true)
	get_node("CollisionArea").set_pickable(true)
	set_pos(get_parent().locations[self.coords].get_pos())
	add_anim_count()
	get_node("Tween").interpolate_property(get_node("Physicals"), "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").interpolate_property(get_node("Shadow"), "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	if blocking:
		emit_signal("animation_done")
	subtract_anim_count()
	

func initialize(cursor_area, flags):
	self.cursor_area = cursor_area
	add_to_group("player_pieces")
	if flags.has("no_inspire"):
		pass
	else:
		get_node("SelectedGlow").initialize(self.assist_type)
		
func added_to_grid():
	pass
	
func animate_reactivate():
	get_node("Physicals/CooldownSprite").show()
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
	
	#for moving on and off the unit select bar
	if coords.y == 99:
		set_opacity(0.5)
	else:
		set_opacity(1.0)
	
	if !self.deploying_flag:
		var seen_range = get_parent().get_range(self.coords, [1, 2], "ENEMY")
		for coords in seen_range:
			if get_parent().pieces[coords].cloaked:
				get_parent().pieces[coords].set_cloaked(false)

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
		get_node("Physicals/OverlayLayers/White").hide()
		if get_parent().selected == null:
			#print(get_name() + " is calling clearing display state in unhovered" )
			get_parent().clear_display_state()



#called when hovered over during player turn		
func hovered():
	if self.state != States.DEAD:
		get_node("Timer").set_wait_time(0.01)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
		if !self.mid_animation:
			hover_highlight()
		
		if get_parent().selected == null and self.state != States.PLACED:
			display_action_range()

func star_input_event(event):
	if self.state == States.PLACED:
		star_reactivate() #reactivate this piece for finishing
		return true
	else:
		return false

#called when an event happens inside the click area hitput
func input_event(event, has_selected):
	if self.deploying_flag: #if in deploy phase
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
	get_parent().selected = self
	hovered()
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
			get_parent().selected = null
		else:
			set_coords(target.coords)
			set_global_pos(target.get_global_pos())
			get_parent().selected = null

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
	if ending_turn:
		clear_assist()
	else:
		handle_assist()
	if self.state != States.PLACED:
		add_animation(self, "animate_placed", false, [ending_turn])
	get_node("SelectedGlow").hide()
	self.state = States.PLACED
	self.attack_bonus = 0
	self.movement_value = self.DEFAULT_MOVEMENT_VALUE
	get_parent().selected = null
	

func animate_placed(ending_turn=false):
	#get_node("Physicals/OverlayLayers/UltimateWhite").hide()
	#get_node("Physicals/AnimatedSprite").play("cooldown")
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

func attacked(attacker):
	return smashed(attacker)


func handle_nonlethal_shove(shover):
	pass



func get_sprite():
	return get_node("Physicals/AnimatedSprite").get_sprite_frames().get_frame("default", 0)
	
func is_enemy():
	return false
	
func displays_line():
	return false

#OVERRIDEN OR INHERITED FUNCTIONS
func act(new_coords):
	return false

func display_action_range():
	pass
#	for coords in get_ally_shove_range():
#		get_parent().get_at_location(coords).assist_highlight()
	
func cast_ultimate():
	pass



