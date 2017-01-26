
extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var action_highlighted = false
var movement_value = Vector2(0, 1)
var default_movement_value = Vector2(0, 1)
var mid_trailing_animation = false
var predicting_hp = false


var coords #enemies move automatically each turn a certain number of spaces forward
var hp
var shielded = false
var deadly = false

var temp_display_hp #what we reset to when resetting prediction, in case original hp is already changed

var type

var prediction_flyover = null

const flyover_prototype = preload("res://EnemyPieces/Components/Flyover.tscn")

signal broke_defenses

var hover_description

var modifier_descriptions = {}


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


func input_event(event):
	if event.is_action("select"):
		if event.is_pressed():
			get_parent().set_target(self)


func hover_highlight():
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")


	if self.action_highlighted:
		get_node("Physicals/EnemyOverlays/White").show()
		get_node("Physicals/HealthDisplay/WhiteLayer").show()
		if get_parent().selected != null:
			get_parent().selected.predict(self.coords)

	
func hover_unhighlight():
	get_node("Physicals/EnemyOverlays/White").hide()
	get_node("Physicals/HealthDisplay/WhiteLayer").hide()
	if self.action_highlighted:
		if get_parent().selected != null:
			get_parent().reset_prediction()

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	self.action_highlighted = true
	get_node("Physicals/EnemyOverlays/Red").show()
	get_node("Physicals/HealthDisplay/RedLayer").show()

#called from grid to reset highlighting over the whole board
func reset_highlight(right_click_flag=false):
	self.action_highlighted = false
	get_node("Physicals/EnemyOverlays/White").hide()
	get_node("Physicals/HealthDisplay/WhiteLayer").hide()
	
	get_node("Physicals/EnemyOverlays/Orange").hide()
	get_node("Physicals/HealthDisplay/OrangeLayer").hide()
	#reset_prediction_flyover() #it's this one lol
	
	get_node("Physicals/EnemyOverlays/Red").hide()
	get_node("Physicals/HealthDisplay/RedLayer").hide()


func reset_prediction_highlight():
	reset_prediction_flyover()
	get_node("Physicals/EnemyOverlays/Orange").hide()
	get_node("Physicals/HealthDisplay/OrangeLayer").hide()
	if self.action_highlighted:
		get_node("Physicals/EnemyOverlays/Red").show()
		get_node("Physicals/HealthDisplay/RedLayer").show()
	


func attack_highlight():
	self.action_highlighted = true
	get_node("Physicals/EnemyOverlays/Red").show()
	get_node("Physicals/HealthDisplay/RedLayer").show()

	
func will_die_to(damage):
	return (self.hp - damage) <= 0
	
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
		get_node("Physicals/HealthDisplay/OrangeLayer").show()
		if self.action_highlighted:
			get_node("Physicals/EnemyOverlays/Red").hide()
			get_node("Physicals/HealthDisplay/RedLayer").hide()
	if self.shielded:
		get_node("/root/AnimationQueue").enqueue(self, "animate_predict_hp", false, [self.hp, 0, color])
	else:
		get_node("/root/AnimationQueue").enqueue(self, "animate_predict_hp", false, [max(self.hp - damage, 0), -1 * damage, color])
		

func animate_smash_killed():
	get_node("Physicals").hide()

	
func set_stunned(flag):
	self.stunned = flag
	if flag:
		get_node("Physicals/EnemyEffects/StunSpiral").show()
	else:
		get_node("Physicals/EnemyEffects/StunSpiral").hide()


func set_deadly(flag):
	self.deadly = flag
	var name = get_node("/root/constants").enemy_modifiers["Poisonous"]
	if flag:
		self.modifier_descriptions[name] = get_node("Physicals/EnemyEffects").descriptions[name]
		get_node("Physicals/EnemyEffects/DeathTouch").show()
	else:
		if self.modifier_descriptions.has(name):
			self.modifier_descriptions.erase(name)
		get_node("/root/AnimationQueue").enqueue(self, "animate_deadly_hide", false)
		
func animate_deadly_hide():
	get_node("Physicals/EnemyEffects/DeathTouch").hide()

func set_shield(flag):
	self.shielded = flag
	var name = get_node("/root/constants").enemy_modifiers["Shield"]
	if flag:
		self.modifier_descriptions[name] = get_node("Physicals/EnemyEffects").descriptions[name]
		get_node("Physicals/EnemyEffects/Bubble").show()
	else:
		if self.modifier_descriptions.has(name):
			self.modifier_descriptions.erase(name)
		get_node("/root/AnimationQueue").enqueue(self, "animate_bubble_hide", false)


func animate_bubble_hide():
	get_node("Physicals/EnemyEffects/Bubble").hide()

	
func set_hp(hp):
	self.hp = hp
	self.temp_display_hp = self.hp
	
func initialize_hp(hp):
	self.hp = hp
	self.temp_display_hp = self.hp
	get_node("Physicals/HealthDisplay/Label").set_text(str(hp))


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


func heal(amount, aoe=false, delay=0.0):
	modify_hp(amount, aoe, delay)


func attacked(amount, aoe=false):
	if self.shielded:
		set_shield(false)
	else:
		modify_hp(amount * -1, aoe)


#for the berserker's smash kill which should instantly remove
func smash_killed(damage, aoe=false):
	get_node("/root/AnimationQueue").enqueue(self, "animate_smash_killed", false)
	attacked(damage, aoe)


#always leaves them with 1 hp
func nonlethal_attacked(damage):
	if self.shielded:
		set_shield(false)
	else:
		var amount = damage * -1
		self.hp = (max(1, self.hp + amount))
		get_node("/root/AnimationQueue").enqueue(self, "animate_set_hp", false, [self.hp, amount])


func modify_hp(amount, aoe=false, delay=0):
	if hp != 0: #in the case that someone tries to modify hp after the unit is already in the process of dying
		hp = (max(0, hp + amount))
		self.temp_display_hp = hp
		get_node("/root/AnimationQueue").enqueue(self, "animate_set_hp", false, [hp, amount, delay])
		 
		if hp == 0 and !aoe: #if aoe, then we manually do the delete self check afterwards
			delete_self()


func aoe_death_check():
	if hp == 0:
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


func delete_self():
	get_parent().remove_piece(self.coords)

func animate_delete_self():
	print("animating deleting self")
	get_node("Sprinkles").update() #update particleattractor location after all have moved
	remove_from_group("enemy_pieces")
	get_node("Tween").interpolate_property(get_node("Physicals"), "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Sprinkles").animate_sprinkles()
	yield(get_node("Sprinkles"), "animation_done")
	get_node("/root/Combat/ComboSystem").increase_combo()
	self.queue_free()

func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords
	

func get_movement_value():
	return self.movement_value


func aura_update():
	pass
	
func reset_auras():
	self.movement_value = self.default_movement_value

#called at the start of enemy turn, after checking for aura effects
func turn_update():
	
	set_z(0)
	if self.stunned:
		set_stunned(false)
	else:
		self.push(movement_value)
	reset_auras()