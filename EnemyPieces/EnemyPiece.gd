
extends "res://Piece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var action_highlighted = false
var movement_value = Vector2(0, 1)
var mid_trailing_animation = false

var coords #enemies move automatically each turn a certain number of spaces forward
var hp
var type
var side = "ENEMY"

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
		
		get_node("Physicals/LightenLayer").show()
		get_node("Physicals/HealthDisplay/LightenLayer").show()
		if get_parent().selected != null:
			get_parent().selected.predict(self.coords)

	
func hover_unhighlight():
	emit_signal("hide_description")
	if self.action_highlighted:
		get_node("Physicals/LightenLayer").hide()
		get_node("Physicals/HealthDisplay/LightenLayer").hide()
		if get_parent().selected != null:
			get_parent().reset_prediction()

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	self.action_highlighted = true
	get_node("Physicals/AnimatedSprite").play("attack_range")
	get_node("Physicals/HealthDisplay/AnimatedSprite").play("attack_range")

#called from grid to reset highlighting over the whole board
func reset_highlight():
	self.action_highlighted = false
	get_node("Physicals/LightenLayer").hide()
	get_node("Physicals/HealthDisplay/LightenLayer").hide()
	
	get_node("Physicals/AnimatedSprite").show()
	get_node("Physicals/HealthDisplay/AnimatedSprite").show()
	get_node("Physicals/PredictionLayer").hide()
	get_node("Physicals/HealthDisplay/PredictionLayer").hide()
	
	get_node("Physicals/AnimatedSprite").play("default")
	get_node("Physicals/HealthDisplay/AnimatedSprite").play("default")
	
func reset_prediction_highlight():
	get_node("Physicals/AnimatedSprite").show()
	get_node("Physicals/HealthDisplay/AnimatedSprite").show()
	get_node("Physicals/PredictionLayer").hide()
	get_node("Physicals/HealthDisplay/PredictionLayer").hide()
	
func attack_highlight():
	get_node("Physicals/AnimatedSprite").play("attack_range")
	get_node("Physicals/HealthDisplay/AnimatedSprite").play("attack_range")

	
func will_die_to(damage):
	return (self.hp - damage) <= 0


func predict(damage, is_passive_damage=false):
	if is_passive_damage:
		get_node("Physicals/AnimatedSprite").hide()
		get_node("Physicals/PredictionLayer").show()
		get_node("Physicals/HealthDisplay/AnimatedSprite").hide()
		get_node("Physicals/HealthDisplay/PredictionLayer").show()
	

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
func nonlethal_attacked(amount):
	var amount = amount * -1
	self.hp = (max(1, self.hp + amount))
	get_node("/root/AnimationQueue").enqueue(self, "animate_set_hp", false, [self.hp, amount])

func modify_hp(amount):
	self.hp = (max(0, self.hp + amount))
	get_node("/root/AnimationQueue").enqueue(self, "animate_set_hp", false, [self.hp, amount])
	if self.hp <= 0:
		delete_self()


func animate_set_hp(hp, value):
	self.mid_trailing_animation = true
	if value < 0:
		get_node("AnimationPlayer").play("FlickerAnimation")
		yield( get_node("AnimationPlayer"), "finished" )

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
	get_node("Tween").interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.3, Tween.TRANS_EXPO, Tween.EASE_OUT_IN)
	get_node("Tween").interpolate_property(text, "visibility/opacity", 1, 0, 1.3, Tween.TRANS_EXPO, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	remove_child(flyover)
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