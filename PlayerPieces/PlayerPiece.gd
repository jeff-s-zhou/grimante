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
	
func set_invulnerable():
	self.invulnerable_flag =  self.AssistSystem.get_bonus_invulnerable()
	#TODO: animations
	
func set_assist_flag(flag):
	self.assist_flag = flag

func handle_assist():
	if self.assist_flag:
		self.assist_flag = false
		self.AssistSystem.activate_assist(self.assist_type)
	else:
		self.AssistSystem.clear_assist()

func get_movement_value():
	return self.AssistSystem.get_bonus_movement() + movement_value
	
func activate_finisher():
	self.state = States.DEFAULT
	#get_node("Cooldown").hide()
	#get_node("Physicals/AnimatedSprite").play("default")
	if(get_node("CollisionArea").overlaps_area(self.cursor_area)):
		self.hovered()
	self.finisher_flag = true

func set_armor(value):
	self.armor = value
	get_node("Physicals/ArmorDisplay/Label").set_text(str(value))

#called once the unit positions are finalized in the deployment phase
func deploy():
	self.deploying_flag = false
	
func set_cooldown(cooldown):
	self.cooldown = cooldown + 1 #offset for the first countdown tick
	
func get_ally_shove_range():
	return get_parent().get_range(self.coords, [1, 2], "PLAYER")
	
func _is_within_ally_shove_range(coords):
	return coords in get_ally_shove_range()
	
	
func is_placed():
	return self.state == States.PLACED

func delete_self():
	print("deleting_self in " + str(self.unit_name) + ":" + str(self.coords))
	get_parent().remove_piece(self.coords)
	remove_from_group("player_pieces")
	

func initialize(cursor_area):
	self.cursor_area = cursor_area
	add_to_group("player_pieces")
	
func turn_update():
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
	

#ANIMATION FUNCTIONS


#move from tile to tile
func animate_stepped_move(old_coords, new_coords, pathed_range, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var path = []
	var current_pathed_coords = pathed_range[new_coords]
	while(current_pathed_coords.coords != old_coords):
		path.push_front(current_pathed_coords.coords)
		current_pathed_coords = current_pathed_coords.previous
	for coords in path:
		var location = get_parent().locations[coords]
		var new_position = location.get_pos()
		animate_move_to_pos(new_position, speed, trans_type, ease_type)
		yield(get_node("Tween"), "tween_complete")

	if blocking:
		emit_signal("animation_done")
		

	
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
		get_node("SamplePlayer").play("tile_hover")
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
		
		#can't begin casting ultimate if mid ultimate already, or ultimate already spent previously
		elif get_parent().selected == self \
		and !self.ultimate_used_flag \
		and !self.ultimate_flag \
		and get_node("/root/global").ultimates_enabled_flag: 
			get_node("UltimateBar").begin_charging()

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
	print("selecting action target")
	#deploy TODO
	get_parent().reset_highlighting()
	get_parent().reset_prediction()
	get_node("BlueGlow").hide()
	if self.deploying_flag:
		print("deploying select action target")
		deploy_select_action_target(target)
	else:
		act(target.coords)


func start_deploy_phase():
	print("met the start deploy phase thing?")
	self.state = States.DEFAULT
	self.deploying_flag = true

	
func _is_within_deploy_range(coords):
	return coords in get_node("/root/Combat").level.deploy_tiles
	
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
	get_node("/root/AnimationQueue").enqueue(self, "animate_placed", false)
	get_node("BlueGlow").hide()
	self.state = States.PLACED
	self.attack_bonus = 0
	self.movement_value = self.DEFAULT_MOVEMENT_VALUE
	get_parent().selected = null
	

func animate_placed():
	get_node("Physicals/OverlayLayers/UltimateWhite").hide()
	if(self.cooldown > 0):
		self.cooldown -= 1
		get_node("Cooldown").show()
		get_node("Cooldown/Label").set_text(str(self.cooldown))
	get_node("Physicals/AnimatedSprite").play("cooldown")

func dies_to_collision(pusher):
	if pusher != null and pusher.side != self.side:  #if there's a pusher and not on the same side
		if pusher.side == "KING":
			return true
		else:
			return pusher.deadly or pusher.hp >= self.armor #if the enemy has same or more hp than the pusher's armor, or the pusher enemy is deadly
		

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
	for coords in get_ally_shove_range():
		get_parent().get_at_location(coords).assist_highlight()
	
func cast_ultimate():
	pass



