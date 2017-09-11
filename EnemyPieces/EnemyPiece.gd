
extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

const YELLOW_EXPLOSION_SCENE = preload("res://EnemyPieces/Components/YellowExplosionParticles.tscn")
const GREEN_EXPLOSION_SCENE = preload("res://EnemyPieces/Components/GreenExplosionParticles.tscn")
const RED_EXPLOSION_SCENE = preload("res://EnemyPieces/Components/RedExplosionParticles.tscn")
const BLACK_EXPLOSION_SCENE = preload("res://EnemyPieces/Components/BlackExplosionParticles.tscn")
const TYPES = {"assist":"assist", "attack":"attack", "selfish":"selfish", "boss":"boss"}
var type

var explosion_prototype = self.YELLOW_EXPLOSION_SCENE



var action_highlighted = false
var movement_value = Vector2(0, 1)
var default_movement_value = Vector2(0, 1)
var mid_trailing_animation = false
var predicting_hp = false

var hp

var deadly = false
var cloaked = false
var predator = false
var corrosive = false

var bleeding = false
var frozen = false
var silenced = false
var stunned = false
var corsair_marked = false

var boss_flag = false

var temp_display_hp #what we reset to when resetting prediction, in case original hp is already changed

var prototype = null

var prediction_flyover = null

const flyover_prototype = preload("res://EnemyPieces/Components/Flyover.tscn")

signal broke_defenses

signal enemy_death

var hover_description = "" setget , get_hover_description

var modifier_descriptions = {} setget , get_modifier_descriptions

func get_hover_description():
	if self.cloaked:
		return "This unit is Cloaked. Attack it or move a Unit adjacent to it to reveal its identity."
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
		

func set_boss(flag):
	self.boss_flag = flag
	if flag:
		get_node("Physicals/SpecialGlow").show()
	else:
		get_node("Physicals/SpecialGlow").hide()
	


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("CollisionArea").connect("mouse_enter", self, "hovered")
	get_node("CollisionArea").connect("mouse_exit", self, "unhovered")
	get_node("Physicals/HealthDisplay").set_z(2)
	#self.check_global_seen()
	self.side = "ENEMY"
	#set_opacity(0)


func initialize(unit_name, hover_description, movement_value, max_hp, modifiers, prototype, type):
	self.unit_name = unit_name
	self.hover_description = hover_description
	self.movement_value = movement_value
	self.default_movement_value = movement_value
	self.prototype = prototype
	self.type = type
	if self.type == TYPES.assist:
		self.explosion_prototype = YELLOW_EXPLOSION_SCENE
	elif self.type == TYPES.attack:
		self.explosion_prototype = RED_EXPLOSION_SCENE
	elif self.type == TYPES.selfish:
		self.explosion_prototype = GREEN_EXPLOSION_SCENE
	elif self.type == TYPES.boss:
		self.explosion_prototype = BLACK_EXPLOSION_SCENE
		
	
	initialize_hp(max_hp)
	if modifiers != null:
		initialize_modifiers(modifiers)
		
func start_deploy_phase():
	self.deploying_flag = true
	
#called once the hero positions are finalized in the deployment phase
func deploy():
	self.deploying_flag = false
	
func added_to_grid():
	add_to_group("enemy_pieces")
	add_animation(self, "animate_summon", false)
	
func set_hp(hp):
	self.hp = hp
	self.temp_display_hp = self.hp


func initialize_hp(hp):
	self.hp = hp
	self.temp_display_hp = self.hp
	get_node("Physicals/HealthDisplay").set_health(hp)


func initialize_modifiers(modifiers):
	#it'll be a dict when created through the level editor, array when programmed for convenience
	if typeof(modifiers) == TYPE_DICTIONARY:
		modifiers = modifiers.values()
	var enemy_modifiers = get_node("/root/constants").enemy_modifiers
	for modifier in modifiers:
		if modifier == enemy_modifiers["Poisonous"]:
			self.set_deadly(true)
		elif modifier == enemy_modifiers["Shield"]:
			self.set_shield(true)
		elif modifier == enemy_modifiers["Cloaked"]:
			self.set_cloaked(true)
		elif modifier == enemy_modifiers["Predator"]:
			self.set_predator(true)
		elif modifier == enemy_modifiers["Corrosive"]:
			self.set_corrosive(true)


func get_modifiers():
	var modifiers = {}
	var enemy_modifiers = get_node("/root/constants").enemy_modifiers
	if self.deadly:
		modifiers["Poisonous"] = enemy_modifiers["Poisonous"]
	if self.shielded:
		modifiers["Shield"] = enemy_modifiers["Shield"]
	if self.cloaked:
		modifiers["Cloaked"] = enemy_modifiers["Cloaked"]
	if self.predator:
		modifiers["Predator"] = enemy_modifiers["Predator"]
	if self.corrosive:
		modifiers["Corrosive"] = enemy_modifiers["Corrosive"]
	return modifiers


func input_event(event, has_selected):
	if event.is_pressed():
		self.grid.set_target(self)


func hovered():
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	if self.action_highlighted:
		get_node("Physicals/EnemyOverlays/White").show()
		self.grid.predict(self.coords)
	
	
func unhovered():
	get_node("Physicals/EnemyOverlays/White").hide()
	if self.action_highlighted and self.grid.selected != null:
		self.grid.reset_prediction()

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	if !self.deploying_flag:
		self.action_highlighted = true
		get_node("Physicals/EnemyOverlays/Red").show()

#called from self.grid to reset highlighting over the whole board
func clear_display_state():
	self.action_highlighted = false
	get_node("Physicals/EnemyOverlays/White").hide()
	get_node("Physicals/EnemyOverlays/Orange").hide()
	get_node("Physicals/EnemyOverlays/Red").hide()
	reset_prediction_flyover()


func reset_prediction_highlight():
	reset_prediction_flyover()
	get_node("Physicals/EnemyOverlays/Orange").hide()
	if self.action_highlighted:
		#if you hover a red piece with a indirect attack, it hides the red and shows orange
		#so we need to reshow the red afterwards
		get_node("Physicals/EnemyOverlays/Red").show() 
	


func attack_highlight():
	self.action_highlighted = true
	get_node("Physicals/EnemyOverlays/Red").show()
	
func get_actual_damage(damage):
	if self.boss_flag:
		if damage > 1:
			damage = 1
		else:
			damage = 0

	if self.shielded:
		return 0
	else:
		return damage
	
func will_die_to(damage):
	var actual_damage = get_actual_damage(damage)
	return (self.hp - actual_damage) <= 0


func reset_prediction_flyover():
	if self.predicting_hp:
		self.predicting_hp = false
		get_node("Physicals/HealthDisplay/AnimationPlayer").stop()
		get_node("Physicals/HealthDisplay").set_health(self.hp)
		if self.prediction_flyover != null:
			self.prediction_flyover.queue_free()
			self.prediction_flyover = null


func animate_predict_hp(hp, value, color):
	if get_parent().selected != null:
		self.predicting_hp = true
		self.temp_display_hp = self.hp
		get_node("Physicals/HealthDisplay/AnimationPlayer").play("HealthFlicker")
		yield(get_node("Physicals/HealthDisplay/AnimationPlayer"), "finished")
		
		get_node("Physicals/HealthDisplay").set_health(hp)
		
		if self.prediction_flyover != null:
			self.prediction_flyover.queue_free()
			self.prediction_flyover = null
			get_node("Physicals/HealthDisplay").set_health(hp)
		
#		if self.predicting_hp:
			#right here is the conditional check
		self.prediction_flyover = self.flyover_prototype.instance()
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
			
		var destination = text.get_pos() - Vector2(0, 60)
		var tween = Tween.new()
		add_child(tween)
		
		tween.interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.2, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_complete") #this is the problem line...fuuuuck
		#self.predicting_hp = false
		tween.queue_free()



func predict(damage, is_passive_damage=false):
	var actual_damage = get_actual_damage(damage)
	var color = Color(1, 0, 0.4)
	if is_passive_damage:
		color = Color(1, 1, 0.0)
		get_node("Physicals/EnemyOverlays/Orange").show()
		if self.action_highlighted:
			get_node("Physicals/EnemyOverlays/Red").hide()
	
	add_animation(self, "animate_predict_hp", false, [max(self.hp - actual_damage, 0), -1 * actual_damage, color])
		

	
func set_stunned(flag):
	if flag and !self.shielded:
		self.stunned = true
		add_animation(self, "animate_set_stunned", false)
	else:
		self.stunned = false
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
	add_anim_count()
	get_node("Physicals/FogEffect/Particles2D").set_emitting(true)
	get_node("SeenIcon").set_opacity(0)
	get_node("Physicals/AnimatedSprite").hide()
	get_node("Physicals/HealthDisplay").hide()
	get_node("Physicals/EnemyEffects").hide()
	get_node("Physicals/EnemyOverlays/Cloaked").show()
	get_node("Physicals/FogEffect").show()
	subtract_anim_count()



func animate_cloaked_hide():
	add_anim_count()
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
	subtract_anim_count()

		
			
func is_deadly():
	return self.deadly

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
	if self.shielded != flag:
		self.shielded = flag
		var name = get_node("/root/constants").enemy_modifiers["Shield"]
		update_description(flag, name)
		add_animation(self, "animate_set_shield", false, [flag])

func animate_set_shield(flag):
	if flag:
		get_node("Physicals/EnemyEffects/Bubble").show()
	else:
		get_node("SamplePlayer").play("window glass break smash 2")
		get_node("Physicals/EnemyEffects").animate_shield_explode()


	

func set_corrosive(flag):
	self.corrosive = flag
	var name = get_node("/root/constants").enemy_modifiers["Corrosive"]
	update_description(flag, name)
	add_animation(self, "animate_set_corrosive", false, [flag])
	
func animate_set_corrosive(flag):
	get_node("Physicals/EnemyEffects/CorrosiveParticles").set_emitting(flag)


func set_predator(flag):
	self.predator = flag
	var name = get_node("/root/constants").enemy_modifiers["Predator"]
	update_description(flag, name)
	add_animation(self, "animate_set_predator", false, [flag])

func animate_set_predator(flag):
	get_node("Physicals/EnemyEffects/RabidParticles").set_emitting(flag)


func set_bleeding(flag):
	if flag and !self.shielded:
		self.bleeding = true
		add_animation(self,"animate_bleeding", false)
	else:
		self.bleeding = false
		add_animation(self,"animate_bleeding_hide", false)
		

func is_corsair_marked():
	return self.corsair_marked
		
func set_corsair_marked(flag):
	if flag:
		self.corsair_marked = true
		add_animation(self,"animate_bleeding", false)
	else:
		self.corsair_marked = false
		add_animation(self,"animate_bleeding_hide", false)

func animate_bleeding():
	add_anim_count()
	get_node("Physicals/EnemyEffects/BurningEffect").show()
	subtract_anim_count()
	
func animate_bleeding_hide():
	add_anim_count()
	get_node("Physicals/EnemyEffects/BurningEffect").hide()
	subtract_anim_count()
		
func animate_fire():
	add_anim_count()
	get_node("Physicals/EnemyEffects/FireEffect").set_emitting(true)
	get_node("Timer").set_wait_time(0.3)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	get_node("Physicals/EnemyEffects/FireEffect").set_emitting(false)
	
	emit_signal("animation_done")
	subtract_anim_count()
	
		
func set_frozen(flag):
	if flag and !self.shielded:
		self.frozen = true
		set_stunned(true)
		add_animation(self,"animate_freeze", false)
		
	else:
		self.frozen = false
		add_animation(self, "animate_freeze_hide", false)
		
		
func animate_freeze():
	get_node("Physicals/EnemyEffects/FrozenEffect").show()
	get_node("Physicals/EnemyEffects/FrozenParticles").set_emitting(true)

func animate_freeze_hide():
	get_node("Physicals/EnemyEffects/FrozenEffect").hide()
	get_node("Physicals/EnemyEffects/FrozenParticles").set_emitting(false)
	
func set_silenced(flag):
	if flag:
		set_shield(false)
		set_deadly(false)
		set_predator(false)
		set_corrosive(false)
		add_animation(self, "animate_silenced", false)
		get_node("CollisionArea").set_pickable(true)
	else:
		add_animation(self, "animate_unsilenced", false)
	self.silenced = flag
	
func animate_silenced():
	get_node("Physicals/EnemyOverlays/AnimationPlayer").play("Default")
	
func animate_unsilenced():
	get_node("Physicals/EnemyOverlays/AnimationPlayer").play("Hide")

func animate_burning_hide():
	get_node("Physicals/EnemyEffects/BurningEffect").hide()



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


func heal(amount, delay=0.0):
	modify_hp(amount, delay)


func attacked(amount, delay=0.0):
	var damage = get_actual_damage(amount)
	
	if self.shielded:
		set_shield(false)
	
	modify_hp(damage * -1, delay)
	
	var tile = get_parent().locations[coords]
	
	#TODO put this through an action call
	if tile.raining:
		var action = get_new_action()
		action.add_call("lightning_attacked", [], self.coords)
		action.execute()
	

func corsair_attacked(damage):
	if !self.shielded:
		set_corsair_marked(true)
	attacked(damage)
	
	
		
func lightning_attacked():
	var tile = get_parent().locations[coords]
	add_animation(tile, "animate_lightning", false)
	modify_hp(-2)

#called by the assassin's passive
#func opportunity_attacked(amount):
#	#set_cloaked(false) we don't need this, right?
#	if self.shielded:
#		set_shield(false)
#	else:
#		modify_hp(amount * -1)


func modify_hp(amount, delay=0):
	if self.hp != 0: #in the case that someone tries to modify hp after the unit is already in the process of dying
		self.hp = min((max(0, self.hp + amount)), 9) #has to be between 0 and 9
		self.temp_display_hp = self.hp
		
#		if self.current_animation_sequence == null:
#			get_new_animation_sequence()
		if self.hp == 0:
			add_animation(self, "animate_set_hp", false, [self.hp, amount, delay])
			delete_self()
			#set_animation_sequence_blocking()
		else:
			add_animation(self, "animate_set_hp", false, [self.hp, amount, delay])
#			
#		enqueue_animation_sequence()


func delete_self():
	add_animation(self, "animate_delete_self", false)
	get_node("CollisionArea").set_pickable(false)
	self.grid.remove_piece(self.coords)
	remove_from_group("enemy_pieces")
	emit_signal("enemy_death")


func animate_set_hp(hp, value, delay=0, flicker_flag=true):
	add_anim_count()
	reset_prediction_flyover()
	#reset_just_prediction_flyover() #if you forget why you need this, attack same enemy quickly with 2 heroes
	self.mid_trailing_animation = true
	if delay > 0:
		var timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(delay)
		timer.start()
		yield(timer, "timeout")
		timer.queue_free()

	get_node("Physicals/HealthDisplay").set_health(hp)
	
	if flicker_flag and value < 0:
		emit_signal("small_shake")
		get_node("Physicals/Cracks").crack()
		get_node("SamplePlayer").play("rocket glass explosion thud 2")

	

	var flyover = self.flyover_prototype.instance()
	add_child(flyover)
	var text = flyover.get_node("FlyoverText")
	var value_text = str(value)
	if value > 0:
		value_text = "+" + value_text
		text.set("custom_colors/font_color", Color(0,1,0))
	elif value == 0:
		value_text = "-" + value_text
	elif flicker_flag:
		get_node("AnimationPlayer").play("FlickerAnimation")
	text.set_opacity(1.0)
	
	text.set_text(value_text)
	
	var destination = text.get_pos() - Vector2(0, 130)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.3, Tween.TRANS_EXPO, Tween.EASE_OUT_IN)
	tween.interpolate_property(text, "visibility/opacity", 1, 0, 1.3, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start()
	
	yield(tween, "tween_complete")
	#if we don't flicker, we won't have it blocking either
	if flicker_flag:
		emit_signal("animation_done")
	flyover.queue_free()
	tween.queue_free()
	
	self.mid_trailing_animation = false
	subtract_anim_count()
	
func walk_off(coords_distance, exits_bottom=true):
	add_animation(self, "animate_walk_off", true, [coords_distance])
	self.grid.remove_piece(self.coords)
	remove_from_group("enemy_pieces")
	if exits_bottom:
		emit_signal("broke_defenses")


#actually physically deletes it
func animate_delete_self():
	add_anim_count()
	get_node("SamplePlayer").play("rocket glass explosion 5")
	get_node("Physicals").set_opacity(0)
	emit_signal("shake")
	var explosion = self.explosion_prototype.instance()
	add_child(explosion)
	explosion.set_emit_timeout(0.3)
	explosion.set_emitting(true)
	
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(0.5)
	timer.start()
	yield(timer, "timeout")
	
	emit_signal("animation_done")
	subtract_anim_count()
	
	#let it resolve any lingering animations
	timer.set_wait_time(3)
	timer.start()
	yield(timer, "timeout")
	print("enemy deleting self")
	print(self.debug_anim_counter)
	timer.queue_free()
	queue_free()


func set_coords(new_coords, sequence=null):
	self.grid.move_piece(self.coords, new_coords)
	self.coords = new_coords
	var location = self.grid.locations[self.coords]
	


func get_movement_value():
	return self.movement_value
	
func reset_auras():
	self.movement_value = self.default_movement_value


func add_modifier_sets(set1, set2):
	for key in set1:
		if !set2.has(key):
			set2[key] = set1[key]
			
	return set2
	
func turn_start():
	pass

#called at the start of enemy turn, after checking for aura effects
func turn_update():
	set_corsair_marked(false)
	set_z(0)
	turn_update_helper()
	reset_auras()

#called after all pieces finish moving
func turn_attack_update():
	if self.bleeding:
		var action = get_new_action()
		action.add_call("attacked", [1], self.coords)
		action.execute()
	
	if self.frozen:
		set_frozen(false)
	
	if self.stunned:
		set_stunned(false)


#this is written so we can easily add more stuff to the end of the turn_update before executing the animation_sequence
func turn_update_helper():
	if !self.stunned and self.hp != 0:
		self.move_attack(movement_value)
		
	
func move_attack(distance):
	#leap the respective distance. If it kills, move to the tile. If it doesn't, leap back.
	var new_coords = self.coords + distance
	
	#successfully walked off
	if !get_parent().locations.has(new_coords):
		walk_off(distance)
		
	#has something to attack
	elif get_parent().pieces.has(new_coords) and get_parent().pieces[new_coords].side == "PLAYER":
		add_animation(self, "animate_move_and_hop", true, [new_coords, 300])
		var success = get_parent().pieces[new_coords].attacked(self)
			
		if success:
			set_coords(new_coords)
		else:
			add_animation(self, "animate_move_and_hop", false, [self.coords, 300, false])
	
	elif get_parent().pieces.has(new_coords) and get_parent().pieces[new_coords].side == "ENEMY":
		return
	
	#otherwise just move forward
	else:
		add_animation(self, "animate_move_and_hop", false, [new_coords, 300, false])
		set_coords(new_coords)
#
func is_enemy():
	return true

func summon_buff(health, modifiers):
	heal(health)
	if modifiers != null:
		initialize_modifiers(modifiers)

		
func deathrattle():
	if self.frozen and self.hp == 0:
		var neighbor_coords_range = get_parent().get_range(self.coords, [1,2], "ENEMY")
		var action = get_new_action()
		action.add_call("attacked", [2], neighbor_coords_range)
		action.execute()
			
func queue_free():
	if is_in_group("enemy_pieces"):
		remove_from_group("enemy_pieces")
	.queue_free()