
extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"

const STATES = {"default":0, "moving":1}
const MOVE_SPEED = 4
var animation_state = STATES.default
var action_highlighted = false
var velocity
var new_position
var movement_value = Vector2(0, 1)

var coords #enemies move automatically each turn a certain number of spaces forward
var hp
var type
var side = "ENEMY"

signal broke_defenses
signal turn_finished

signal pre_damage

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	get_node("ClickArea").connect("mouse_enter", self, "hover_highlight")
	get_node("ClickArea").connect("mouse_exit", self, "hover_unhighlight")
	get_node("Physicals/AnimatedSprite").set_z(-2)
	get_node("Physicals/HealthDisplay").set_z(0)
	get_node("Flyover").set_z(1)
	add_to_group("enemy_pieces")
	
func hover_highlight():
	if self.action_highlighted:
		get_node("Physicals/AnimatedSprite").play("attack_range_hover")
		get_node("Physicals/HealthDisplay/AnimatedSprite").play("attack_range_hover")
	
func hover_unhighlight():
	if self.action_highlighted:
		get_node("Physicals/AnimatedSprite").play("attack_range")
		get_node("Physicals/HealthDisplay/AnimatedSprite").play("attack_range")

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	self.action_highlighted = true
	get_node("Physicals/AnimatedSprite").play("attack_range")
	get_node("Physicals/HealthDisplay/AnimatedSprite").play("attack_range")
	
func unhighlight():
	self.action_highlighted = false
	get_node("Physicals/AnimatedSprite").play("default")
	get_node("Physicals/HealthDisplay/AnimatedSprite").play("default")
	
func attack_highlight():
	get_node("Physicals/AnimatedSprite").play("attack_range")
	get_node("Physicals/HealthDisplay/AnimatedSprite").play("attack_range")


func animate_summon():
	get_node("AnimationPlayer").play("SummonAnimation")
	
func set_hp(hp):
	if hp <= 0:
		self.hp = 0
		delete_self()
	else:
		self.hp = hp
	get_node("Physicals/HealthDisplay/Label").set_text(str(self.hp))
	
func delete_self():
	get_parent().pieces.erase(self.coords)
	remove_from_group("enemy_pieces")
	get_node("/root/Combat/ComboSystem").increase_combo()
	yield(get_node("Tween"), "tween_complete")
	self.queue_free()
	
	
func attacked(damage):
	get_node("AnimationPlayer").play("FlickerAnimation")
	set_hp(self.hp - damage)
	yield( get_node("AnimationPlayer"), "finished" )

	var text = get_node("Flyover/FlyoverText")
	text.set_pos(Vector2(-25, 16))
	text.set_opacity(1.0)
	text.set_text("-" + str(damage))
	var destination = text.get_pos() - Vector2(0, 200)
	get_node("Tween").interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.3, Tween.TRANS_EXPO, Tween.EASE_OUT_IN)
	get_node("Tween").interpolate_property(text, "visibility/opacity", 1, 0, 1.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()


#for the berserker's smash kill which should instantly remove
func smash_killed(damage):
	set_hp(self.hp - damage)
	get_node("Physicals").set_opacity(0)
	var text = get_node("Flyover/FlyoverText")
	text.set_pos(Vector2(-25, 16))
	text.set_opacity(1.0)
	text.set_text("-" + str(damage))
	var destination = text.get_pos() - Vector2(0, 150)
	get_node("Tween").interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.5, Tween.TRANS_EXPO, Tween.EASE_OUT_IN)
	get_node("Tween").interpolate_property(text, "visibility/opacity", 1, 0, 1.5, Tween.TRANS_QUINT, Tween.EASE_IN)
	get_node("Tween").start()
	
	
	
	
func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords
	
func push(distance):
	if get_parent().locations.has(self.coords + distance):
		#if there's something in front, push that
		if get_parent().pieces.has(self.coords + distance):
			get_parent().pieces[self.coords + distance].push(distance)
			
		animate_move(self.coords + distance)
		set_coords(self.coords + distance)
		yield(get_node("Tween"), "tween_complete")
		
	else:
		delete_self()
	

func animate_move_to_pos(position, speed):
	var distance = get_pos().distance_to(position)
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	

func animate_move(new_coords, speed=200):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed)


func get_movement_value():
	return self.movement_value


#called at the start of enemy turn
func turn_update():
	if !get_parent().locations.has(coords + movement_value):
		emit_signal("broke_defenses")
		delete_self()
	else:
		if get_parent().pieces.has(coords + movement_value):
			#if a player piece, move it first
			var obstructing_piece = get_parent().pieces[coords + movement_value]
			obstructing_piece.push(movement_value)
				
		#now if the space in front is free, move it
		if !get_parent().pieces.has(coords + movement_value):
			animate_move(coords + movement_value)
			set_coords(coords + movement_value)
			yield(get_node("Tween"), "tween_complete")
			emit_signal("turn_finished")
			