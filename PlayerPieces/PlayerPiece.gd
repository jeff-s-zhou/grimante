extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var States = {"LOCKED":0, "DEFAULT":1, "CLICKED": 2, "PLACED":3, "SELECTED":4}

onready var AssistSystem = get_node("/root/Combat/AssistSystem")

onready var ASSIST_TYPES = AssistSystem.ASSIST_TYPES

var assist_type = null

var deploying_flag = false

var overview_description
var attack_description
var passive_description
var ultimate_description

var state = States.PLACED
var cursor_area

var cooldown = 0

var assist_flag = false

var invulnerable_flag = false

var ultimate_available_flag = false

var ultimate_flag = false

var ultimate_used_flag = false

var finisher_flag = false

var armor = 0
var movement_value = 1 setget , get_movement_value
var attack_bonus = 0

const SHOVE_SPEED = 4

signal invalid_move
signal shake

signal pre_attack(attack_coords)

signal stepped_move_completed

signal targeted

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hovered")
	get_node("ClickArea").connect("mouse_exit", self, "unhovered")
	
	set_process_input(true)
	self.side = "PLAYER"
	
func get_assist_bonus_attack():
	return self.AssistSystem.get_bonus_attack()
	
func deploy_placed():
	self.state = States.PLACED

#call this function right before being assisted
func handle_pre_assisted():
	self.AssistSystem.assist(self)
	set_invulnerable(self.AssistSystem.get_bonus_invulnerable())

func set_invulnerable(flag):
	if self.invulnerable_flag != flag:
		self.invulnerable_flag = flag
		add_animation(self, "animate_set_invulnerable", false, [self.invulnerable_flag])
	
func animate_set_invulnerable(flag):
	if flag:
		get_node("Physicals/OverlayLayers/UltimateWhite").show()
	else:
		get_node("Physicals/OverlayLayers/UltimateWhite").hide()
	
	
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

	
func assist(piece, assist_type):
	add_animation(self, "animate_assist", true, [piece, assist_type])

#direct the particles to a certain coords
func animate_assist(piece, assist_type):
	add_anim_count()
	print("reached this call")
	var pos_difference = piece.get_pos() - get_pos()
	get_node("Physicals/ComboSparkleManager").animate_assist(assist_type, pos_difference)
	yield(get_node("Physicals/ComboSparkleManager"), "animation_done")
	emit_signal("animation_done")
	subtract_anim_count()

	
func clear_assist():
	add_animation(get_node("Physicals/ComboSparkleManager"), "animate_clear_assist", false, [self.assist_type])


func get_movement_value():
	return self.AssistSystem.get_bonus_movement() + movement_value
	
func activate_finisher():
	if !self.finisher_flag and self.cooldown == 0:
		#TODO: sparkly effects
		self.finisher_flag = true
	
func finisher_reactivate():
	var player_pieces = get_tree().get_nodes_in_group("player_pieces")
	for player_piece in player_pieces:
		self.finisher_flag = false
	self.state = States.DEFAULT
	get_node("Cooldown").hide()
	get_node("Physicals/AnimatedSprite").play("default")
	if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
		self.hovered()

func set_armor(value):
	self.armor = value
	get_node("Physicals/ArmorDisplay/Label").set_text(str(value))

#called once the unit positions are finalized in the deployment phase
func deploy():
	self.deploying_flag = false
	
func block_summon():
	if !self.invulnerable_flag:
		delete_self()
		add_animation(self, "animate_delete_self", true)
	
func set_cooldown(cooldown):
	self.cooldown = cooldown + 1 #offset for the first countdown tick
	
func get_ally_shove_range():
	return get_parent().get_range(self.coords, [1, 2], "PLAYER")
	
func _is_within_ally_shove_range(coords):
	return coords in get_ally_shove_range()
	
	
func is_placed():
	return self.state == States.PLACED

func delete_self():
	var location = get_parent().locations[self.coords]
	location.add_corpse(self)
	add_animation(location, "animate_add_corpse", false)
	get_parent().remove_piece(self.coords)
	remove_from_group("player_pieces")


func animate_delete_self(blocking=true):
	add_anim_count()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	if blocking:
		emit_signal("animation_done")
	subtract_anim_count()


func resurrect():
	add_to_group("player_pieces")
	get_parent().add_piece(self.coords, self)
	add_animation(self, "animate_summon", false)


func animate_resurrect(blocking=true):
	add_anim_count()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	if blocking:
		emit_signal("animation_done")
	subtract_anim_count()
	

func initialize(cursor_area):
	self.cursor_area = cursor_area
	add_to_group("player_pieces")
	
func turn_update():
	set_invulnerable(false)
	set_z(0)
	if self.cooldown > 0:
		pass
	else:
		self.state = States.DEFAULT
		get_node("Cooldown").hide()
		get_node("Physicals/AnimatedSprite").play("default")
		if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
			self.hovered()


func set_coords(new_coords):
	get_parent().move_piece(self.coords, new_coords)
	self.coords = new_coords
	
	var seen_range = get_parent().get_range(self.coords, [1, 2], "ENEMY")
	for coords in seen_range:
		if get_parent().pieces[coords].cloaked:
			get_parent().pieces[coords].set_cloaked(false)
			
	var res_range = get_parent().get_location_range(self.coords)
	for coords in res_range:
		if get_parent().locations[coords].corpse != null:
			var location = get_parent().locations[coords]
			location.resurrect()
			add_animation(location, "animate_hide_corpse", false)
	

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
	
func assist_highlight():
	get_node("Physicals/OverlayLayers/Green").show()


#called when the whole board's highlighting is reset
func reset_highlight(right_click_flag=false):
	get_node("Physicals/OverlayLayers/White").hide()
	get_node("Physicals/OverlayLayers/Green").hide()
	if(self.state != States.PLACED):
		get_node("Physicals/AnimatedSprite").play("default")
		
	if right_click_flag and get_node("CollisionArea").overlaps_area(self.cursor_area):
			self.hovered()
#	else:
#		get_node("Physicals/AnimatedSprite").play("cooldown")

func reset_prediction_highlight():
	pass
	#get_node("Physicals/Physicals/AnimatedSprite").show()
	#get_node("Physicals/PredictionLayer").hide()
	

#called on mouse entering the ClickArea
func hover_highlight():
	
	if(self.state != States.PLACED):
		#get_node("SamplePlayer").play("tile_hover")
		get_node("Physicals/OverlayLayers/White").show()
	else:
		print("is placed")


#called on mouse exiting the ClickArea
func unhovered():
	get_node("Physicals/OverlayLayers/White").hide()
	if get_parent().selected == null:
		get_parent().reset_highlighting()
#		
#	elif get_parent().selected == self:
#		reset_highlight()
		

#called when hovered over during player turn		
func hovered():
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	if !self.mid_animation:
		hover_highlight()
	
	if get_parent().selected == null and self.state != States.PLACED:
		display_action_range()



#called when an event happens inside the click area hitput
func input_event(event):
	if self.deploying_flag: #if in deploy phase
		deploy_input_event(event)
		return
	#deploy TODO
	if event.is_action("select") and !event.is_pressed() and get_node("UltimateBar").ultimate_charging:
		get_node("UltimateBar").end_charging()

	if event.is_action("select") and event.is_pressed():
		if get_parent().selected == null and self.state != States.PLACED:
			select()
		
		elif get_parent().selected == null and self.finisher_flag:
			finisher_reactivate() #reactivate this piece for finishing

		else: #if not selected and not self, then some piece is trying to act on this one
			get_parent().set_target(self)
			
			
func deploy_input_event(event):
	if event.is_action("select") and event.is_pressed():
		if get_parent().selected == null:
			select()
		else:
			get_parent().set_target(self)


func select():
	get_parent().selected = self
	hovered()
	get_node("SamplePlayer").play("mouseover")
	self.state = States.CLICKED
	get_node("BlueGlow").show()


func deselect():
	self.state = States.DEFAULT
	get_node("BlueGlow").hide()


func select_action_target(target):
	#deploy TODO
	get_parent().reset_highlighting()
	get_parent().reset_prediction()
	get_node("BlueGlow").hide()
	if self.deploying_flag:
		deploy_select_action_target(target)
	else:
		act(target.coords)


func start_deploy_phase():
	self.state = States.DEFAULT
	self.deploying_flag = true

	
func _is_within_deploy_range(coords):
	return get_node("/root/Combat").is_within_deploy_range(coords)
	
	
func deploy_select_action_target(target):
	if _is_within_deploy_range(target.coords):
		if get_parent().pieces.has(target.coords) and target.side == "PLAYER":
			swap_coords_and_pos(target)
			get_parent().selected = null
		else:
			set_coords(target.coords)
			set_pos(target.get_pos())
			get_parent().selected = null
	else:
		invalid_move()
		
func swap_coords_and_pos(target):
	get_parent().swap_pieces(self.coords, target.coords)
	var temp_coords = self.coords
	self.coords = target.coords
	target.coords = temp_coords
	
	#set the positions
	set_pos(get_parent().locations[self.coords].get_pos())
	target.set_pos(get_parent().locations[target.coords].get_pos())
	



#helper function for act
func invalid_move():
	get_parent().reset_highlighting()
	get_parent().reset_prediction()
	get_node("BlueGlow").hide()
	emit_signal("invalid_move")
	self.state = States.DEFAULT
	get_parent().selected = null

#helper function for act

func placed():
	self.handle_assist()
	add_animation(self, "animate_placed", false)
	get_node("BlueGlow").hide()
	self.state = States.PLACED
	self.attack_bonus = 0
	self.movement_value = self.DEFAULT_MOVEMENT_VALUE
	get_parent().selected = null
	

func animate_placed():
	#get_node("Physicals/OverlayLayers/UltimateWhite").hide()
	if(self.cooldown > 0):
		self.cooldown -= 1
		get_node("Cooldown").show()
		get_node("Cooldown/Label").set_text(str(self.cooldown))
	get_node("Physicals/AnimatedSprite").play("cooldown")
	
	
func player_attacked(enemy, animation_sequence=null):
	if dies_to_collision(enemy):
		delete_self()
		if animation_sequence != null: #if it's part of another unit's animation sequence
			animation_sequence.add(self, "animate_delete_self", true)
		else:
			add_animation(self, "animate_delete_self", true)
		

func dies_to_collision(pusher):
	if pusher != null and pusher.side != self.side:  #if there's a pusher and not on the same side
		#if not invulnerable and the enemy has same or more hp than the pusher's armor, or the pusher enemy is deadly
		return !self.invulnerable_flag and (pusher.is_deadly() or pusher.hp >= self.armor) 
		

#shove is different than push
func initiate_friendly_shove(coords):
	var offset = get_parent().hex_normalize(coords - self.coords)
	var shoved_coords = coords + offset
	if(get_parent().locations.has(shoved_coords) and !get_parent().pieces.has(shoved_coords)):
		var location = get_parent().locations[coords]
		var difference = (location.get_pos() - get_pos()) / 3
		var collide_pos = get_pos() + difference 
		get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [collide_pos, 300, true]) #push up against it
		get_parent().pieces[coords].receive_friendly_shove(shoved_coords)
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [coords, 300, false])
		set_coords(coords)
		placed()
	else:
		invalid_move()
		
func receive_friendly_shove(destination_coords):
	get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [destination_coords, 300, false])
	set_coords(destination_coords)


#OVERRIDEN OR INHERITED FUNCTIONS
func act(new_coords):
	return false

func display_action_range():
	pass
#	for coords in get_ally_shove_range():
#		get_parent().get_at_location(coords).assist_highlight()
	
func cast_ultimate():
	pass



