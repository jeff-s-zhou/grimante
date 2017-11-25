extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var side = null

const Action = preload("res://Action.gd")
const AnimationSequence = preload("res://AnimationSequence.gd")

signal animation_done
signal count_animation_done

signal shake
signal big_shake
signal small_shake

var current_animation_sequence = null

var debug_anim_counter = 0

var mid_animation = false

var mid_leaping_animation = false

var unit_name = "" setget , get_unit_name

var shielded = false

var deploying_flag = false

var coords #enemies move automatically each turn a certain number of spaces forward

onready var grid = get_parent()

func get_unit_name():
	return unit_name
	
func debug():
	#get_node("DebugText").show()
	get_node("DebugText").set_text(str(self.debug_anim_counter) + "\n" + str(get_z()))

func _ready():
	pass
	get_node("CollisionArea").connect("area_enter", self, "collide")
	get_node("CollisionArea").connect("area_exit", self, "uncollide")
	
func set_targetable(flag):
	get_node("CollisionArea").set_pickable(flag)
		
func is_targetable():
	return get_node("CollisionArea").is_pickable()
	
func add_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(1)
	self.debug_anim_counter += 1
	self.mid_animation = true
	
func subtract_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(-1)
	self.debug_anim_counter -=1
	self.mid_animation = false


func get_new_action(trigger_assassin_passive=true):
	var action = self.Action.new(self, trigger_assassin_passive)
	add_child(action)
	return action
	
func get_new_animation_sequence(blocking=false, stateful=true):
	get_node("/root/AnimationQueue").update_waiting_count(1)
	var sequence = self.AnimationSequence.new(blocking)
	add_child(sequence)
	if stateful:
		self.current_animation_sequence = sequence
	return sequence
	
func set_animation_sequence_blocking():
	if self.current_animation_sequence != null:
		self.current_animation_sequence.blocking = true

func add_animation(node, func_ref, blocking, arguments=[]):
	if self.current_animation_sequence != null:
		self.current_animation_sequence.add(node, func_ref, blocking, arguments)
	else:
		get_node("/root/AnimationQueue").enqueue(node, func_ref, blocking, arguments)

func update_animation_count(amount):
	if self.current_animation_sequence != null:
		self.current_animation_sequence.update_animation_count(amount)
	else:
		get_node("/root/AnimationQueue").update_animation_count(amount)

func enqueue_animation_sequence():
	get_node("/root/AnimationQueue").update_waiting_count(-1)
	if self.current_animation_sequence != null:
		if !self.current_animation_sequence.is_empty():
			get_node("/root/AnimationQueue").enqueue(self.current_animation_sequence, "execute", self.current_animation_sequence.blocking)
		self.current_animation_sequence = null
			
	else:
		print("called enqueue_animation_sequence when there is none")


func collide(area):
	if area.get_name() != "CursorArea":
		var other_piece = area.get_parent()
		if !other_piece.mid_leaping_animation and !self.mid_leaping_animation: #If leaping, it'll set its own z above everythin else
			var other_piece = area.get_parent()
			if other_piece.get_pos().y > get_pos().y:
				other_piece.set_z(get_z() + 1)
			else:
				other_piece.set_z(get_z() - 1)
#
#a little buggy currently, since both the offender and receiver of a collision can both be mid animation
#we just let them reset each other for now, and make sure neither are mid_leaping_animation
func uncollide(area):
	if area.get_name() != "CursorArea": #make sure it's not the thing that checks for mouse inside areas
		var other_piece = area.get_parent()
		if self.mid_animation and !self.mid_leaping_animation and !other_piece.mid_leaping_animation:
			other_piece.set_z(0)
#		

func set_mid_animation(flag):
	self.mid_animation = flag
	
func animate_summon():
	pass

func animate_summon2():
	add_anim_count()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	subtract_anim_count()

	
func animate_move_to_pos(position, speed, blocking=false, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN, delay=0):
	add_anim_count()
	var tween = Tween.new()
	add_child(tween)
	
	var distance = get_pos().distance_to(position)
	if distance == 0:
		var timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(0.01)
		timer.start()
		yield(timer, "timeout")
		timer.queue_free()
		if blocking:
			emit_signal("animation_done")
	else:
		
		var dim_distance = dim_multi_distance(distance)
		print("got dim distance")
		tween.interpolate_property(self, "transform/pos", get_pos(), position, float(dim_distance)/speed, trans_type, ease_type, delay)
		tween.start()
		yield(tween, "tween_complete")
		tween.queue_free()
		if blocking:
			emit_signal("animation_done")
			
	subtract_anim_count()


func animate_move(new_coords, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	add_anim_count()
	var location = self.grid.locations[new_coords]
	var position = location.get_pos()
	
	var distance = get_pos().distance_to(position)
	var dim_distance = dim_multi_distance(distance)
	var time = dim_distance/speed
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, time, trans_type, ease_type)
	get_node("Tween").start()
	if blocking:
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")
		subtract_anim_count()
	else:
		subtract_anim_count()
	
func animate_move_and_hop(new_coords, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	add_anim_count()
	var location = self.grid.locations[new_coords]
	var position = location.get_pos()
	
	var distance = get_pos().distance_to(position)
	var dim_distance = dim_multi_distance(distance)
	var time = dim_distance/speed
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "transform/pos", get_pos(), position, time, trans_type, ease_type)
	tween.start()
	animate_short_hop(speed, new_coords)
	if blocking:
		yield(tween, "tween_complete")
		#need this in because apparently Tween emits the signal slightly early
		get_node("Timer").set_wait_time(0.03)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
		emit_signal("animation_done")
		subtract_anim_count()
		tween.queue_free()
	else:
		yield(tween, "tween_complete")
		subtract_anim_count()
		tween.queue_free()

func animate_short_hop(speed, new_coords):
	#add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	animate_short_hop_to_pos(speed, distance)

func dim_multi_distance(distance):
	var x = distance/400 #400 is how far the biggest jump is
	var y = ((-1 * pow(3, -1 * x)) + 1)/x
	return round(y * distance)

func animate_short_hop_to_pos(speed, distance):
	var dim_distance = dim_multi_distance(distance)
	var time = dim_distance/speed
	time = max(0.30, time) #if short hop looks weird, switch this back to 0.35

	var old_height = Vector2(0, -5)
	var vertical = min(-2 * distance/3, -60)
	var new_height = Vector2(0, vertical)
	
	var tween = Tween.new()
	add_child(tween)

	tween.interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_height, time/2, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_complete")
	
	tween.interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_height, time/2, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete")
	tween.queue_free()
	set_z(0)
	self.mid_leaping_animation = false
	#emit_signal("animation_done")
	#subtract_anim_count()
	

func walk_off(coords_distance):
	pass

func animate_walk_off(coords_distance):
	add_anim_count()
	var speed = 300
	var distance = get_parent().get_real_distance(coords_distance)
	var time = distance.length()/speed
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), get_pos() + distance, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 1, 0, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	animate_short_hop_to_pos(speed, distance.length())
	yield(get_node("Tween"), "tween_complete")
	#need this in because apparently Tween emits the signal slightly early
	get_node("Timer").set_wait_time(0.1)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	subtract_anim_count()
	get_node("Timer").set_wait_time(1)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	self.queue_free()



func handle_shifting_sands():
	var location = self.grid.locations[self.coords]
	if location.shifting_direction != null:
		var change_vector = self.grid.get_change_vector(location.shifting_direction)
		self.move(change_vector)
		location.rotate_shifting()
		

func hooked(new_coords):
	add_animation(self, "animate_move", false, [new_coords, 600, false, Tween.TRANS_QUAD])
	set_coords(new_coords)
	
	
func fireball_attacked(damage):
	pass


func receive_shove(distance, damage):
	var new_coords = self.coords + distance
	
	var unit_distance = get_parent().hex_normalize(distance)
	#gets knocked off
	if !get_parent().locations.has(new_coords):
		if unit_distance == Vector2(0, 1) and self.side == "ENEMY":
			walk_off(distance)
		else:
			walk_off(distance, false) #delete self instead of triggering a lose condition
		
	#will land on something
	elif get_parent().pieces.has(new_coords):
		add_animation(self, "animate_receive_shove_noise", false)
		add_animation(self, "animate_move_and_hop", true, [new_coords, 300])
		var action = get_new_action()
		if get_parent().pieces[new_coords].side == "ENEMY":
			action.add_call("attacked", [damage, self], [new_coords])
		else:
			action.add_call("attacked", [self], [new_coords])
		action.execute()
		if get_parent().pieces.has(new_coords): #leap backwards if something's still there
			add_animation(self, "animate_move_and_hop", false, [self.coords, 300, false])
		else: #means this piece can move to the tile
			set_coords(new_coords)

	#otherwise just move forward
	else:
		add_animation(self, "animate_receive_shove_noise", false)
		add_animation(self, "animate_move_and_hop", false, [new_coords, 300, false])
		set_coords(new_coords)


func animate_receive_shove_noise():
	get_node("SamplePlayer").play("rocket glass explosion thud 2")

		
func handle_nonlethal_shove(pusher):
	pass


func dies_to_collision(pusher):
	return false
	
func star_input_event(event):
	return false


func is_slime():
	return false

func is_enemy():
	return false