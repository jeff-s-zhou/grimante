extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var side = null

const Action = preload("res://Action.gd")
const AnimationSequence = preload("res://AnimationSequence.gd")

signal animation_done
signal count_animation_done

var current_animation_sequence = null

var mid_animation = false

var mid_leaping_animation = false

var stunned = false

var unit_name = "" setget , get_unit_name

var coords #enemies move automatically each turn a certain number of spaces forward

onready var grid = get_parent()

func get_unit_name():
	return unit_name
	
func debug():
	#get_node("DebugText").show()
	get_node("DebugText").set_text(str(self.mid_animation) + "\n" + str(self.coords))

func _ready():
	pass
#	get_node("CollisionArea").connect("area_enter", self, "collide")
#	get_node("CollisionArea").connect("area_exit", self, "uncollide")
	
func add_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(1)
	self.mid_animation = true
	
func subtract_anim_count():
	get_node("/root/AnimationQueue").update_animation_count(-1)
	self.mid_animation = false


func get_new_action(coords_or_range, trigger_assassin_passive=true):
	var action = self.Action.new(coords_or_range, self, trigger_assassin_passive)
	add_child(action)
	return action
	
func get_new_animation_sequence(blocking=false):
	get_node("/root/AnimationQueue").update_waiting_count(1)
	self.current_animation_sequence = self.AnimationSequence.new(blocking)
	add_child(self.current_animation_sequence)
	return self.current_animation_sequence
	


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


func set_seen(flag):
	if flag:
		get_node("SeenIcon").hide()
		get_node("/root/global").seen_units[self.unit_name] = true
		#hide all other similar icons by calling them to re-check against the global seen list
		if self.side == "ENEMY":
			for enemy_piece in get_tree().get_nodes_in_group("enemy_pieces"):
				if enemy_piece != self:
					enemy_piece.check_global_seen()
		elif self.side == "PLAYER":
			for player_piece in get_tree().get_nodes_in_group("player_pieces"):
				if player_piece != self:
					player_piece.check_global_seen()
	else:
		get_node("SeenIcon").show()


func check_global_seen():
	if get_node("/root/global").seen_units.has(self.unit_name):
		get_node("SeenIcon").hide()
	else:
		get_node("SeenIcon").show()


#func collide(area):
#	pass
#	if area.get_name() != "CursorArea":
#		if self.mid_animation and !self.mid_leaping_animation: #If leaping, it'll set its own z above everythin else
#			var other_piece = area.get_parent()
#			if other_piece.get_pos().y > get_pos().y:
#				other_piece.set_z(get_z() + 1)
#			else:
#				other_piece.set_z(get_z() - 1)
#
#a little buggy currently, since both the offender and receiver of a collision can both be mid animation
#we just let them reset each other for now, and make sure neither are mid_leaping_animation
#func uncollide(area):
#	if area.get_name() != "CursorArea": #make sure it's not the thing that checks for mouse inside areas
#		var other_piece = area.get_parent()
#		if self.mid_animation and !self.mid_leaping_animation and !other_piece.mid_leaping_animation:
#			other_piece.set_z(0)
		

func set_mid_animation(flag):
	self.mid_animation = flag

func animate_summon():
	add_anim_count()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	subtract_anim_count()

	
func animate_move_to_pos(position, speed, blocking=false, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	add_anim_count()
	var tween = Tween.new()
	add_child(tween)
	var distance = get_pos().distance_to(position)
	tween.interpolate_property(self, "transform/pos", get_pos(), position, float(distance)/speed, trans_type, ease_type)
	tween.start()
	if blocking:
		yield(tween, "tween_complete")
		tween.queue_free()
		emit_signal("animation_done")
		subtract_anim_count()
	else:
		subtract_anim_count()


func animate_move(new_coords, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	add_anim_count()
	var location = self.grid.locations[new_coords]
	var position = location.get_pos()
	
	var distance = get_pos().distance_to(position)
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, trans_type, ease_type)
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
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, trans_type, ease_type)
	get_node("Tween").start()
	animate_short_hop(speed, new_coords)
	if blocking:
		yield(get_node("Tween"), "tween_complete")
#		get_node("Timer").set_wait_time(0.1)
#		get_node("Timer").start()
#		yield(get_node("Timer"), "timeout")
		emit_signal("animation_done")
		subtract_anim_count()
	else:
		subtract_anim_count()
		
	
func animate_short_hop(speed, new_coords):
	#add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	
	#var one_tile_travelled = 115
	#var time = 100 * (distance/one_tile_travelled)/speed
	var time = distance/speed
	time = max(0.35, time)

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

func handle_shifting_sands():
	var location = self.grid.locations[self.coords]
	if location.shifting_direction != null:
		var change_vector = self.grid.get_change_vector(location.shifting_direction)
		self.move(change_vector)
		self.enqueue_animation_sequence()
		

func hooked(new_coords):
	add_animation(self, "animate_move", true, [new_coords, 300, true])
	set_coords(new_coords)
	

func move(distance, passed_animation_sequence=null):
	var animation_sequence
	if passed_animation_sequence != null:
		animation_sequence = passed_animation_sequence
		self.current_animation_sequence = animation_sequence
	else:
		animation_sequence = get_new_animation_sequence()

	var old_coords = self.coords
	
	var distance_length = self.grid.hex_length(distance)
	var distance_increment = self.grid.hex_normalize(distance)
	var direction = self.grid.get_direction_from_vector(distance)
	var collide_range = self.grid.get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
	var collide_coords = null
	
	#if there's something in front, we shove it
	if collide_range.size() > 0:
		collide_coords = collide_range[0]
		if self.coords != collide_coords - distance_increment: 
			move_helper(collide_coords - distance_increment, animation_sequence, true)
	else: #else just move forward all the way
		move_helper(self.coords + distance, animation_sequence, true)
	
	#if there was a collision
	if collide_coords != null:
		var distance_travelled  = self.coords - old_coords
		var remaining_distance = distance - distance_travelled
		self.shove(collide_coords, remaining_distance, animation_sequence)
		self.current_animation_sequence.blocking = true
	#execute the whole sequence outside of the function


#helper function to either move a piece, or have it fall off the map
func move_helper(coords, animation_sequence=null, blocking=false):
	var distance = coords - self.coords 
	var distance_length = self.grid.hex_length(distance)
	var distance_increment = self.grid.hex_normalize(distance)
	var furthest_distance = Vector2(0, 0)
	var walked_off = false
	for i in range(0, distance_length):
		if !get_parent().locations.has(self.coords + (i + 1) * distance_increment):
			walked_off = true
			break
		else:
			furthest_distance = (i + 1) * distance_increment
			
	var furthest_distance_length = self.grid.hex_length(furthest_distance)
	
	var speed = 300 * furthest_distance_length
	if furthest_distance_length > 0:
		
		#if walked off, we block so that delete self is animated sequentially
		animation_sequence.add(self, "animate_move_and_hop", walked_off, [self.coords + furthest_distance, speed, walked_off])
		set_coords(self.coords + furthest_distance)

	if walked_off:
		animation_sequence.blocking = true
		delete_self(animation_sequence)
		if self.side == "ENEMY" and distance_increment == Vector2(0, 1):
			emit_signal("broke_defenses")


#at this point we've moved forward to cover all empty spaces
#with remaining moves, try to push the obstacle immediately in front
func shove(collide_coords, distance, animation_sequence):
	var old_coords = self.coords
	var distance_length = self.grid.hex_length(distance)
	var distance_increment = self.grid.hex_normalize(distance)
	var moves_left = distance_length
	var direction = self.grid.get_direction_from_vector(distance)

	if distance_length > 0:
		
		#push up against it
		var location = self.grid.locations[collide_coords]
		var location_right_before = self.grid.locations[collide_coords - distance_increment]
		var difference =  (location.get_pos() - location_right_before.get_pos())/4
		var old_pos = location_right_before.get_pos()
		var collide_pos = old_pos + difference 
		var new_distance = (self.coords + distance) - collide_coords + self.grid.hex_normalize(distance)

		animation_sequence.add(self, "animate_move_to_pos", true, [collide_pos, 300, true])
		animation_sequence.add(self, "animate_move_to_pos", true, [old_pos, 300, true]) 
		
		var distance_shoved = get_parent().pieces[collide_coords].receive_shove(self, distance, animation_sequence)
		if distance_shoved == null: #that means it killed the piece it shoved
			
			#TODO: this might be broken lol. used to have move helper before the if
			if old_coords + distance != self.coords: #if we still haven't travelled the full distance after killing
				#recursively call move from the position of the first killed player unit
				move(old_coords + distance - self.coords, animation_sequence)
				return
			else:
				move_helper(collide_coords, animation_sequence)
		elif distance_shoved == Vector2(0, 0): #the piece wasn't able to be pushed back then don't leap
			pass
			#animation_sequence.add(self, "animate_move", true, [self.coords, 300, true])
		else:
			move_helper(self.coords + distance_shoved, animation_sequence)


func receive_shove(pusher, distance, animation_sequence):
	if dies_to_collision(pusher): #check if they're going to die from collision
		delete_self(animation_sequence)
		return null


	var old_coords = self.coords
	var distance_length = self.grid.hex_length(distance)
	var distance_increment = self.grid.hex_normalize(distance)
	var direction = self.grid.get_direction_from_vector(distance)
	
	#see if there's a piece behind it blocking things
	var collide_range = self.grid.get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
	var collide_coords = null
	if collide_range.size() > 0:
		collide_coords = collide_range[0]
		if self.coords != collide_coords - distance_increment: 
			move_helper(collide_coords - distance_increment, animation_sequence, true)
			return (self.coords - old_coords)
		else:
			#TODO make it brace up against the piece behind it
			return Vector2(0, 0)
	else:
		move_helper(self.coords + distance, animation_sequence, true)
		
		return distance


func dies_to_collision(pusher):
	return false
	


	