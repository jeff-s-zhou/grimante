
extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var action_highlighted = false
var movement_value = Vector2(0, 1)
var mid_trailing_animation = false
var predicting_hp = false


var coords #enemies move automatically each turn a certain number of spaces forward
var hp
var type

var prediction_flyover = null


const flyover_prototype = preload("res://EnemyPieces/Flyover.tscn")

var hover_description = ""
var unit_name = ""

var reinforced_hp = 0

signal description_data(name, description)
signal hide_description

signal broke_defenses

signal animation_done


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hover_highlight")
	get_node("ClickArea").connect("mouse_exit", self, "hover_unhighlight")
	get_node("Physicals/AnimatedSprite").set_z(-2)
	get_node("Physicals/HealthDisplay").set_z(0)
	add_to_group("enemy_pieces")
	self.side = "ENEMY"
	#set_opacity(0)
	
func input_event(viewport, event, shape_idx):
	if event.is_action("select"):
		if event.is_pressed():
			get_parent().set_target(self)
		
func hover_highlight():
	get_node("Timer").set_wait_time(0.03)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("description_data", self.unit_name, self.hover_description)
	if self.action_highlighted:
		get_node("Physicals/EnemyOverlays/White").show()
		get_node("Physicals/HealthDisplay/WhiteLayer").show()
		if get_parent().selected != null:
			get_parent().selected.predict(self.coords)

	
func hover_unhighlight():
	emit_signal("hide_description")
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
func reset_highlight():
	self.action_highlighted = false
	get_node("Physicals/EnemyOverlays/White").hide()
	get_node("Physicals/HealthDisplay/WhiteLayer").hide()
	
	get_node("Physicals/EnemyOverlays/Orange").hide()
	get_node("Physicals/HealthDisplay/OrangeLayer").hide()
	
	reset_prediction_flyover()
	
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
	get_node("Physicals/HealthDisplay/Label").set_text(str(hp))
	get_node("Physicals/HealthDisplay/Label").show()
	self.predicting_hp = false
	if self.prediction_flyover != null:
		self.prediction_flyover.queue_free()
		#remove_child(self.prediction_flyover)
		self.prediction_flyover = null
		get_node("Physicals/HealthDisplay/Label").set_text(str(hp))

func animate_predict_hp(hp, value, color):
	self.predicting_hp = true
	self.mid_trailing_animation = true
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
		self.prediction_flyover.set_z(1)
		add_child(self.prediction_flyover)
		var text = self.prediction_flyover.get_node("FlyoverText")
		var value_text = str(value)
		text.set("custom_colors/font_color", color)
		if value > 0:
			value_text = "+" + value_text
			text.set("custom_colors/font_color", Color(0,1,0))
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
	self.mid_trailing_animation = false

func predict(damage, is_passive_damage=false):
	var color = Color(1, 0, 0.4)
	if is_passive_damage:
		color = Color(1, 1, 0.0)
		get_node("Physicals/EnemyOverlays/Orange").show()
		get_node("Physicals/HealthDisplay/OrangeLayer").show()
		if self.action_highlighted:
			get_node("Physicals/EnemyOverlays/Red").hide()
			get_node("Physicals/HealthDisplay/RedLayer").hide()
	get_node("/root/AnimationQueue").enqueue(self, "animate_predict_hp", false, [self.hp - damage, -1 * damage, color])
	

#for the berserker's smash kill which should instantly remove
func smash_killed(damage):
	get_node("/root/AnimationQueue").enqueue(self, "animate_smash_killed", false)
	attacked(damage)


func animate_smash_killed():
	get_node("Physicals").set_opacity(0)
	
	
func set_hp(hp):
	self.hp = hp
	get_node("Physicals/HealthDisplay/Label").set_text(str(self.hp))

func heal(amount):
	modify_hp(amount)

func attacked(amount):
	modify_hp(amount * -1)

#always leaves them with 1 hp
func nonlethal_attacked(damage):
	var amount = damage * -1
	self.hp = (max(1, self.hp + amount))
	print("nonlethal_attacked, hp: " + str(self.hp) + ", amount: " + str(amount))
	get_node("/root/AnimationQueue").enqueue(self, "animate_set_hp", false, [self.hp, amount])

func modify_hp(amount):
	self.hp = (max(0, self.hp + amount))
	get_node("/root/AnimationQueue").enqueue(self, "animate_set_hp", false, [self.hp, amount])
	if self.hp <= 0:
		delete_self()
	

func animate_set_hp(hp, value):
	reset_prediction_flyover()
	self.mid_trailing_animation = true
#	var timer = Timer.new()
#	add_child(timer)
	get_node("AnimationPlayer").play("FlickerAnimation")
	#get_node("Physicals/EnemyOverlays/AnimationPlayer").play("DamageFlickerAnimation")
	
#	timer.set_wait_time(1.0)
#	timer.start()
#	yield(timer, "timeout")
#	remove_child(timer)

	get_node("Physicals/HealthDisplay/Label").set_text(str(hp))
	
	var flyover = self.flyover_prototype.instance()
	flyover.set_z(1)
	add_child(flyover)
	var text = flyover.get_node("FlyoverText")
	var value_text = str(value)
	if value > 0:
		value_text = "+" + value_text
		text.set("custom_colors/font_color", Color(0,1,0))
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
#	remove_child(flyover)
#	remove_child(tween)
	self.mid_trailing_animation = false
	
	if hp == 0:
		animate_delete_self()


func delete_self():
	get_parent().remove_piece(self.coords)
	remove_from_group("enemy_pieces")


func animate_delete_self():
	get_node("/root/Combat/ComboSystem").increase_combo()
	self.queue_free()
	

func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords
	

func get_movement_value():
	return self.movement_value


#called at the start of enemy turn
func turn_update():
	if !get_parent().locations.has(coords + movement_value):
		emit_signal("broke_defenses")
		delete_self()
		animate_delete_self()
	else:
		#TODO: refactor all this
		self.push(movement_value)