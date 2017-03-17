
extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var action_highlighted = false
var movement_value = Vector2(0, 1)
var default_movement_value = Vector2(0, 1)
var mid_trailing_animation = false
var predicting_hp = false

var hp
var shielded = false
var deadly = false
var cloaked = false

var burning = false
var frozen = false
var silenced = false

var temp_display_hp #what we reset to when resetting prediction, in case original hp is already changed

var type

var prediction_flyover = null

const flyover_prototype = preload("res://EnemyPieces/Components/Flyover.tscn")

signal broke_defenses

var hover_description = "" setget , get_hover_description

var modifier_descriptions = {} setget , get_modifier_descriptions

func get_hover_description():
	if self.cloaked:
		return ""
	else:
		return hover_description

func get_modifier_descriptions():
	if self.cloaked:
		return {}
	else:
		return modifier_descriptions

func get_unit_name():
	if self.cloaked:
		return "?"
	else:
		return unit_name


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hover_highlight")
	get_node("ClickArea").connect("mouse_exit", self, "hover_unhighlight")
	get_node("Physicals/HealthDisplay").set_z(2)
	add_to_group("enemy_pieces")
	#self.check_global_seen()
	self.side = "ENEMY"
	#set_opacity(0)


func initialize(unit_name, hover_description, movement_value, max_hp, modifiers):
	self.unit_name = unit_name
	self.hover_description = hover_description
	self.movement_value = movement_value
	self.default_movement_value = movement_value
	initialize_hp(max_hp)
	if modifiers != null:
		initialize_modifiers(modifiers)

func input_event(event):
	if event.is_action("select"):
		if event.is_pressed():
			self.grid.set_target(self)


func hover_highlight():
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")


	if self.action_highlighted:
		get_node("Physicals/EnemyOverlays/White").show()
		if self.grid.selected != null:
			self.grid.selected.predict(self.coords)

func debug():
	#get_node("DebugText").show()
	get_node("DebugText").set_text(str(self.coords))
	
	
func hover_unhighlight():
	get_node("Physicals/EnemyOverlays/White").hide()
	if self.action_highlighted:
		if self.grid.selected != null:
			self.grid.reset_prediction()

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	self.action_highlighted = true
	get_node("Physicals/EnemyOverlays/Red").show()

#called from self.grid to reset highlighting over the whole board
func reset_highlight(right_click_flag=false):
	self.action_highlighted = false
	get_node("Physicals/EnemyOverlays/White").hide()
	
	get_node("Physicals/EnemyOverlays/Orange").hide()
	#reset_prediction_flyover() #it's this one lol
	
	get_node("Physicals/EnemyOverlays/Red").hide()


func reset_prediction_highlight():
	reset_prediction_flyover()
	get_node("Physicals/EnemyOverlays/Orange").hide()
	if self.action_highlighted:
		get_node("Physicals/EnemyOverlays/Red").show()
	


func attack_highlight():
	self.action_highlighted = true
	get_node("Physicals/EnemyOverlays/Red").show()

	
func will_die_to(damage):
	return (self.hp - damage) <= 0 and self.shielded == false
	
func reset_prediction_flyover():
	get_node("Physicals/HealthDisplay/AnimationPlayer").stop()
	get_node("Physicals/HealthDisplay/Label").set_text(str(self.temp_display_hp))
	get_node("Physicals/HealthDisplay/Label").show()
	self.predicting_hp = false
	if self.prediction_flyover != null:
		self.prediction_flyover.queue_free()
		self.prediction_flyover = null


func animate_predict_hp(hp, value, color):
	self.predicting_hp = true
	self.temp_display_hp = self.hp
	get_node("Physicals/HealthDisplay/AnimationPlayer").play("HealthFlicker")
	yield(get_node("Physicals/HealthDisplay/AnimationPlayer"), "finished")
	
	get_node("Physicals/HealthDisplay/Label").set_text(str(hp))
	get_node("Physicals/HealthDisplay/Label").show()
	
	if self.prediction_flyover != null:
		self.prediction_flyover.queue_free()
		self.prediction_flyover = null
		get_node("Physicals/HealthDisplay/Label").set_text(str(hp))
	
	if self.predicting_hp:
		#right here is the conditional check
		self.prediction_flyover = self.flyover_prototype.instance()
		self.prediction_flyover.set_z(4)
		add_child(self.prediction_flyover)
		var text = self.prediction_flyover.get_node("FlyoverText")
		var value_text = str(value)
		text.set("custom_colors/font_color", color)
		if value > 0:
			value_text = "+" + value_text
			text.set("custom_colors/font_color", Color(0,1,0))
		elif value == 0:
			value_text = "-" + value_text
		text.set_opacity(1.0)
		self.prediction_flyover.get_node("AnimationPlayer").play("OpacityHover")
		
		if self.cloaked:
			text.set_text("-?")
		else:
			text.set_text(value_text)
			
		var destination = text.get_pos() - Vector2(0, 85)
		var tween = Tween.new()
		add_child(tween)
		
		tween.interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_complete") #this is the problem line...fuuuuck
		tween.queue_free()


func predict(damage, is_passive_damage=false):
	var color = Color(1, 0, 0.4)
	if is_passive_damage:
		color = Color(1, 1, 0.0)
		get_node("Physicals/EnemyOverlays/Orange").show()
		if self.action_highlighted:
			get_node("Physicals/EnemyOverlays/Red").hide()
	if self.shielded:
		add_animation(self, "animate_predict_hp", false, [self.hp, 0, color])
	else:
		add_animation(self, "animate_predict_hp", false, [max(self.hp - damage, 0), -1 * damage, color])
		

func animate_smash_killed():
	get_node("Physicals").hide()

	
func set_stunned(flag):
	self.stunned = flag
	if flag:
		add_animation(self, "animate_set_stunned", false)
	else:
		add_animation(self, "animate_hide_stunned", false)
		
func animate_set_stunned():
	get_node("Physicals/EnemyEffects/StunSpiral").show()

func animate_hide_stunned():
	get_node("Physicals/EnemyEffects/StunSpiral").hide()
	


func update_description(flag, name):
	if flag:
		self.modifier_descriptions[name] = get_node("Physicals/EnemyEffects").descriptions[name]
	elif self.modifier_descriptions.has(name):
		self.modifier_descriptions.erase(name)

func set_cloaked(flag):
	if self.cloaked != flag:
		self.cloaked = flag
		var name = get_node("/root/constants").enemy_modifiers["Cloaked"]
		update_description(flag, name)
		if flag:
			add_animation(self, "animate_cloaked_show", false)
		else:
			add_animation(self, "animate_cloaked_hide", false)


func animate_cloaked_show():
	get_node("Physicals/FogEffect/Particles2D").set_emitting(true)
	get_node("SeenIcon").set_opacity(0)
	get_node("Physicals/AnimatedSprite").hide()
	get_node("Physicals/HealthDisplay").hide()
	get_node("Physicals/EnemyEffects").hide()
	get_node("Physicals/EnemyOverlays/Cloaked").show()
	get_node("Physicals/FogEffect").show()


func animate_cloaked_hide():
	get_node("SeenIcon").set_opacity(1)
	check_global_seen()
	
	var tween = get_node("Tween")
	
	var sprite = get_node("Physicals/AnimatedSprite")
	sprite.set_opacity(0)
	sprite.show()
	
	var health_display = get_node("Physicals/HealthDisplay")
	health_display.set_opacity(0)
	health_display.show()
	
	var enemy_effects = get_node("Physicals/EnemyEffects")
	enemy_effects.set_opacity(0)
	enemy_effects.show()
	
	var cloaked = get_node("Physicals/EnemyOverlays/Cloaked")
	var fog = get_node("Physicals/FogEffect")
	tween.interpolate_property(sprite, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(health_display, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(enemy_effects, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(cloaked, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	#tween.interpolate_property(fog, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete")
	cloaked.hide()
	fog.get_node("Particles2D").set_emitting(false)
		

func set_deadly(flag):
	if self.deadly != flag:
		self.deadly = flag
		var name = get_node("/root/constants").enemy_modifiers["Poisonous"]
		update_description(flag, name)
		if flag:
			add_animation(self, "animate_deadly_show", false)
		else:
			add_animation(self, "animate_deadly_hide", false)

func animate_deadly_show():
	get_node("Physicals/EnemyEffects/DeathTouch").set_emitting(true)

func animate_deadly_hide():
	get_node("Physicals/EnemyEffects/DeathTouch").set_emitting(false)


func set_shield(flag):
	self.shielded = flag
	var name = get_node("/root/constants").enemy_modifiers["Shield"]
	update_description(flag, name)
	if flag:
		add_animation(self, "animate_bubble_show", false)
	else:
		add_animation(self, "animate_bubble_hide", false)
		
func animate_bubble_show():
	get_node("Physicals/EnemyEffects/Bubble").show()

func animate_bubble_hide():
	get_node("Physicals/EnemyEffects/Bubble").hide()
		
func set_burning(flag):
	self.burning = flag
	if flag:
		add_animation(self,"animate_fire", true)
	else:
		add_animation(self,"animate_burning_hide", false)
		
func animate_fire():
	get_node("Physicals/EnemyEffects/FireEffect").set_emitting(true)
	get_node("Timer").set_wait_time(0.3)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	get_node("Physicals/EnemyEffects/FireEffect").set_emitting(false)
	get_node("Physicals/EnemyEffects/BurningEffect").show()
	emit_signal("animation_done")
		
func set_frozen(flag):
	self.frozen = flag
	
func set_silenced(flag):
	if flag:
		set_shield(false)
		set_deadly(false)
	self.silenced = flag

func animate_burning_hide():
	get_node("Physicals/EnemyEffects/BurningEffect").hide()


	
func set_hp(hp):
	self.hp = hp
	self.temp_display_hp = self.hp
	
func initialize_hp(hp):
	self.hp = hp
	self.temp_display_hp = self.hp
	get_node("Physicals/HealthDisplay/Label").set_text(str(hp))
	
func initialize_modifiers(modifiers):
	var enemy_modifiers = get_node("/root/constants").enemy_modifiers
	for modifier in modifiers:
		if modifier == enemy_modifiers["Poisonous"]:
			self.set_deadly(true)
		elif modifier == enemy_modifiers["Shield"]:
			self.set_shield(true)
		elif modifier == enemy_modifiers["Cloaked"]:
			self.set_cloaked(true)


func handle_pre_payload(payload):
	if payload["hp_change"] < 0:
		#handle archer ultimate
		pass
	
func handle_payload(payload):
	if payload["hp_change"] < 0:
		if self.shielded:
			set_shield(false)
		else:
			if payload["effects"] == null:
				pass
			modify_hp(payload["hp_change"])
			
	elif payload["hp_change"] > 0:
		modify_hp(payload["hp_change"])
		
func handle_post_payload(payload):
	if payload["hp_change"] < 0:
		#handle assassin's passive
		pass
	
func resolve_death():
	if hp == 0:
		delete_self()


func heal(amount, delay=0.0):
	modify_hp(amount, delay)


func attacked(amount):
	set_cloaked(false)
	if self.shielded:
		set_shield(false)
	else:
		modify_hp(amount * -1)


#called by the assassin's passive
func opportunity_attacked(amount):
	set_cloaked(false)
	if self.shielded:
		set_shield(false)
	else:
		modify_hp(amount * -1)


#for the berserker's smash kill which should instantly remove
func smash_killed(damage):
	add_animation(self, "animate_smash_killed", false)
	attacked(damage)
	
	
func receive_shield_bash(destination_coords):
	#if it falls off the edge of map
	if !self.grid.locations.has(destination_coords):
		delete_self()
		#var fall_off_distance = 30 * (fall_off_pos - get_pos()).normalized()
		if self.grid.hex_normalize(destination_coords - self.coords) == Vector2(0, 1):
				emit_signal("broke_defenses")
		add_animation(self, "animate_delete_self", false)
		
	#if there's a piece in the destination coords
	elif self.grid.pieces.has(destination_coords):
		if self.grid.pieces[destination_coords].side == "ENEMY":
			var other_enemy_piece = self.grid.pieces[destination_coords]
			#shove itself into the other piece
			var offset = self.grid.hex_normalize(destination_coords - self.coords)
			var location = self.grid.locations[destination_coords]
			var difference = (location.get_pos() - get_pos()) / 3
			var collide_pos = get_pos() + difference 
			add_animation(self, "animate_move_to_pos", true, [collide_pos, 300, true]) #push up against it
			
			#then kill one or the other, depending on which has the higher hp
			if self.hp >= other_enemy_piece.hp:
				other_enemy_piece.receive_shield_bashed_enemy_bash()
				add_animation(self, "animate_move", false, [destination_coords, 300, false])
				set_coords(destination_coords)
			else:
				delete_self()
				add_animation(self, "animate_delete_self", false)
		#TODO: what do we do if it tries to shove an enemy into an ally?
		
	#otherwise just push it
	else:
		add_animation(self, "animate_move", false, [destination_coords, 300, false])
		set_coords(destination_coords)

#can't think of what to call this lol, it's when an enemy is shoved by another enemy that's shield bashed
func receive_shield_bashed_enemy_bash():
	delete_self()
	add_animation(self, "animate_delete_self", false)


func modify_hp(amount, delay=0):
	if self.hp != 0: #in the case that someone tries to modify hp after the unit is already in the process of dying
		self.hp = min((max(0, self.hp + amount)), 9) #has to be between 0 and 9
		self.temp_display_hp = self.hp
		add_animation(self, "animate_set_hp", false, [self.hp, amount, delay])
		if self.hp == 0: #if aoe, then we manually do the delete self check afterwards
			delete_self()
			


func animate_set_hp(hp, value, delay=0):
	reset_prediction_flyover()
	self.mid_trailing_animation = true
	if delay > 0:
		get_node("Timer").set_wait_time(delay)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
	get_node("Physicals/HealthDisplay/Label").set_text(str(hp))
	
	var flyover = self.flyover_prototype.instance()
	flyover.set_z(4)
	add_child(flyover)
	var text = flyover.get_node("FlyoverText")
	var value_text = str(value)
	if value > 0:
		value_text = "+" + value_text
		text.set("custom_colors/font_color", Color(0,1,0))
	else:
		get_node("AnimationPlayer").play("FlickerAnimation")
	text.set_opacity(1.0)
	
	text.set_text(value_text)

	var destination = text.get_pos() - Vector2(0, 200)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.3, Tween.TRANS_EXPO, Tween.EASE_OUT_IN)
	tween.interpolate_property(text, "visibility/opacity", 1, 0, 1.3, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete") #this is the problem line...fuuuuck
	flyover.queue_free()
	tween.queue_free()
	self.mid_trailing_animation = false
	if hp == 0:
		animate_delete_self()


#removes it from the self.grid, which prevents any interaction with other pieces
func delete_self():
	self.grid.remove_piece(self.coords)


#actually physically removes it from the board
func animate_delete_self():
	#get_node("Sprinkles").update() #update particleattractor location after all have moved
	remove_from_group("enemy_pieces")
	get_node("Tween").interpolate_property(get_node("Physicals"), "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	#get_node("Sprinkles").animate_sprinkles()
	#yield(get_node("Sprinkles"), "animation_done")
	get_node("/root/Combat/ComboSystem").increase_combo()
	self.queue_free()

func set_coords(new_coords, sequence=null):
	self.grid.move_piece(self.coords, new_coords)
	self.coords = new_coords
	var location = self.grid.locations[self.coords]
	if location.raining:
		add_animation(location, "animate_lightning", true)
		var action = get_new_action(self.coords)
		action.add_call("attacked", [1])
		action.execute()


func get_movement_value():
	return self.movement_value


func aura_update():
	pass
	
func reset_auras():
	self.movement_value = self.default_movement_value

#called at the start of enemy turn, after checking for aura effects
func turn_update():
	turn_update_helper()
	enqueue_animation_sequence()

#this is written so we can easily add more stuff to the end of the turn_update before executing the animation_sequence
func turn_update_helper():
	if self.burning:
		var action = get_new_action(self.coords)
		action.add_call("attacked", [1])
		action.execute()
	
	set_z(0)
	if self.stunned:
		set_stunned(false)
	elif self.hp != 0:
		self.move(movement_value)
		
	
	if self.silenced:
		set_silenced(false)

	reset_auras()
	
	var adjacent_players_range = self.grid.get_range(self.coords, [1, 2], "PLAYER")
	if adjacent_players_range != []:
		set_cloaked(false)


func summon_buff(health, modifiers):
	heal(health)
	if modifiers != null:
		initialize_modifiers(modifiers)