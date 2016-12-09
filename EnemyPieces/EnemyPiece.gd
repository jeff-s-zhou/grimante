
extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"

var action_highlighted = false
var movement_value = Vector2(0, 1)
var mid_animation = false

var coords #enemies move automatically each turn a certain number of spaces forward
var hp
var type
var side = "ENEMY"

var hover_description = ""
var unit_name = ""

var reinforced_hp = 0

signal description_data(name, description)
signal hide_description

signal broke_defenses
signal turn_finished

signal pre_damage


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ClickArea").connect("mouse_enter", self, "hover_highlight")
	get_node("ClickArea").connect("mouse_exit", self, "hover_unhighlight")
	get_node("Physicals/AnimatedSprite").set_z(-2)
	get_node("Physicals/HealthDisplay").set_z(0)
	get_node("Flyover").set_z(1)
	add_to_group("enemy_pieces")
	#set_opacity(0)
	
func input_event(viewport, event, shape_idx):
	if event.is_action("select"):
		if event.is_pressed():
			print("handling input event for enemy")
			get_parent().set_target(self)
		
func hover_highlight():
	print("highlighting")
	emit_signal("description_data", self.unit_name, self.hover_description)
	if self.action_highlighted:
		get_node("Physicals/AnimatedSprite").play("attack_range_hover")
		get_node("Physicals/HealthDisplay/AnimatedSprite").play("attack_range_hover")

	
func hover_unhighlight():
	emit_signal("hide_description")
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
	if(get_node("Tween").is_active()):
		yield(get_node("Tween"), "tween_complete")
	
	get_node("/root/Combat/ComboSystem").increase_combo()
	remove_from_group("enemy_pieces")
	self.queue_free()
	
	
func attacked(damage):
	mid_animation = true
	get_node("AnimationPlayer").play("FlickerAnimation")
	set_hp(self.hp - damage)
	yield( get_node("AnimationPlayer"), "finished" )
	damaged_helper(damage)


#for the berserker's smash kill which should instantly remove
func smash_killed(damage):
	mid_animation = true
	set_hp(self.hp - damage)
	get_node("Physicals").set_opacity(0)
	damaged_helper(damage)


func damaged_helper(damage):
	var text = get_node("Flyover/FlyoverText")
	text.set_pos(Vector2(-25, 16)) #original position of flyover text
	text.set_opacity(1.0)
	text.set_text("-" + str(damage))
	var destination = text.get_pos() - Vector2(0, 200)
	get_node("Tween").interpolate_property(text, "rect/pos", text.get_pos(), destination, 1.3, Tween.TRANS_EXPO, Tween.EASE_OUT_IN)
	get_node("Tween").interpolate_property(text, "visibility/opacity", 1, 0, 1.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	mid_animation = false
	

func set_coords(coords):
	get_parent().move_piece(self.coords, coords)
	self.coords = coords


func push(distance, is_knight=false):
	if get_parent().locations.has(self.coords + distance):
		#if there's something in front, push that
		if get_parent().pieces.has(self.coords + distance):
			get_parent().pieces[self.coords + distance].push(distance)
			
		animate_move(self.coords + distance)
		set_coords(self.coords + distance)
		yield(get_node("Tween"), "tween_complete")
		
	else:
		#needed because delete self catches a "yield" for tween player
		get_node("Tween").interpolate_property(self, "visibility/opacity", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		get_node("Tween").start()
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
			