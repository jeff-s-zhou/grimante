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

func _ready():
	get_node("CollisionArea").connect("area_enter", self, "collide")
	get_node("CollisionArea").connect("area_exit", self, "uncollide")
	
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
	if self.current_animation_sequence != null:
		
		get_node("/root/AnimationQueue").enqueue(self.current_animation_sequence, "execute", self.current_animation_sequence.blocking)
		self.current_animation_sequence = null


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


func collide(area):
	pass
	if area.get_name() != "CursorArea":
		if self.mid_animation and !self.mid_leaping_animation: #If leaping, it'll set its own z above everythin else
			var other_piece = area.get_parent()
			if other_piece.get_pos().y > get_pos().y:
				other_piece.set_z(get_z() + 1)
			else:
				other_piece.set_z(get_z() - 1)

#a little buggy currently, since both the offender and receiver of a collision can both be mid animation
#we just let them reset each other for now, and make sure neither are mid_leaping_animation
func uncollide(area):
	if area.get_name() != "CursorArea": #make sure it's not the thing that checks for mouse inside areas
		var other_piece = area.get_parent()
		if self.mid_animation and !self.mid_leaping_animation and !other_piece.mid_leaping_animation:
			other_piece.set_z(0)
		

func set_mid_animation(flag):
	self.mid_animation = flag

func animate_summon():
	add_anim_count()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	subtract_anim_count()


#this doesn't actually block properly if you intend to have it block
func animate_delete_self(blocking=true):
	add_anim_count()
	get_node("Tween").interpolate_property(self, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	if blocking:
		emit_signal("animation_done")
	subtract_anim_count()
	self.queue_free()
	

	
func animate_move_to_pos(position, speed, blocking=false, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	add_anim_count()
	var distance = get_pos().distance_to(position)
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, trans_type, ease_type)
	get_node("Tween").start()
	if blocking:
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")
		subtract_anim_count()
	else:
		subtract_anim_count()

	

func animate_move(new_coords, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	add_anim_count()
	var location = self.grid.locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed, false, trans_type, ease_type)
	if(blocking):
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")
	subtract_anim_count()
	
func animate_short_hop(speed, new_coords):
	add_anim_count()
	self.mid_leaping_animation = true
	set_z(3)
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = get_pos().distance_to(new_position)
	var time = distance/speed
	var old_position = Vector2(0, 0)
	var new_position = Vector2(0, -40)
	
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	
	get_node("Tween 2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	set_z(0)
	self.mid_leaping_animation = false
	#emit_signal("animation_done")
	subtract_anim_count()

func shift(change_vector):
	self.move(change_vector)
	self.enqueue_animation_sequence()

func hooked(new_coords):
	add_animation(self, "animate_move", true, [new_coords, 300, true])
	set_coords(new_coords)
	
func move(distance, passed_animation_sequence=null):
	var animation_sequence
	if passed_animation_sequence != null:
		animation_sequence = passed_animation_sequence
	else:
		animation_sequence = self.AnimationSequence.new()
		
	self.current_animation_sequence = animation_sequence
		
	var old_coords = self.coords
	
	var distance_length = self.grid.hex_length(distance)
	var distance_increment = self.grid.hex_normalize(distance)
	var direction = self.grid.get_direction_from_vector(distance)
	var collide_range = self.grid.get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
	var collide_coords = null
	
	#if there's something in front, we shove it
	if collide_range.size() > 0:
		collide_coords = collide_range[0]
		#if the tile right before the one we want to collide with isn't the one we're on
		if self.coords != collide_coords - distance_increment: 
			move_helper(collide_coords - distance_increment, animation_sequence, true)
	else: #else just move forward all the way
		move_helper(self.coords + distance, animation_sequence, true)
	
	#if there was a collision
	if collide_coords != null:
		self.move_attack(collide_coords, animation_sequence)
		self.current_animation_sequence.blocking = true
	#execute the whole sequence outside of the function


func move_attack(collide_coords, animation_sequence):
	var location = self.grid.locations[collide_coords]
	var location_right_before = self.grid.locations[collide_coords - Vector2(0, 1)]
	var difference =  (location.get_pos() - location_right_before.get_pos())/4
	var collide_pos = location_right_before.get_pos() + difference 
	animation_sequence.add(self, "animate_move_to_pos", true, [collide_pos, 300, true])

	var piece_killed = get_parent().pieces[collide_coords].receive_move_attack(self, animation_sequence)
	if piece_killed:
		move_helper(collide_coords, animation_sequence)
	else:
		animation_sequence.add(self, "animate_move", true, [self.coords, 300, true])


func receive_move_attack(pusher, animation_sequence):
	if dies_to_collision(pusher): #check if they're going to die from collision
		delete_self()
		animation_sequence.add(self, "animate_delete_self", true)
		return true
	return false


func move2(distance, passed_animation_sequence=null):
	var animation_sequence
	if passed_animation_sequence != null:
		animation_sequence = passed_animation_sequence
	else:
		animation_sequence = self.AnimationSequence.new()
		
	self.current_animation_sequence = animation_sequence
		
	var old_coords = self.coords
	
	var distance_length = self.grid.hex_length(distance)
	var distance_increment = self.grid.hex_normalize(distance)
	var direction = self.grid.get_direction_from_vector(distance)
	var collide_range = self.grid.get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
	var collide_coords = null
	
	#if there's something in front, we shove it
	if collide_range.size() > 0:
		collide_coords = collide_range[0]
		#if the tile right before the one we want to collide with isn't the one we're on
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

	if furthest_distance != Vector2(0, 0):
		animation_sequence.add(self, "animate_move", blocking, [self.coords + furthest_distance, 300, blocking])
		set_coords(self.coords + furthest_distance)

	if walked_off:
		print("deleting self after walking off")
		delete_self()
		animation_sequence.add(self, "animate_delete_self", true)

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
		var collide_pos = location_right_before.get_pos() + difference 
		var new_distance = (self.coords + distance) - collide_coords + self.grid.hex_normalize(distance)
		animation_sequence.add(self, "animate_move_to_pos", true, [collide_pos, 300, true])
		#get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [collide_pos, 300, true]) 
		
		var distance_shoved = get_parent().pieces[collide_coords].receive_shove(self, distance, animation_sequence)
		if distance_shoved == null: #that means it killed the piece it shoved
			move_helper(collide_coords, animation_sequence)
			if old_coords + distance != self.coords: #if we still haven't travelled the full distance after killing
				#recursively call move from the position of the first killed player unit
				move(old_coords + distance - self.coords, animation_sequence)
				return
		elif distance_shoved == Vector2(0, 0):
			animation_sequence.add(self, "animate_move", true, [self.coords, 300, true])
			#get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords, 300, false])
		else:
			move_helper(self.coords + distance_shoved, animation_sequence)


func receive_shove(pusher, distance, animation_sequence):
	if dies_to_collision(pusher): #check if they're going to die from collision
		delete_self()
		animation_sequence.add(self, "animate_delete_self", true)
		return null


	var old_coords = self.coords
	var distance_length = self.grid.hex_length(distance)
	var distance_increment = self.grid.hex_normalize(distance)
	var direction = self.grid.get_direction_from_vector(distance)
	
	var collide_range = self.grid.get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
	var collide_coords = null
	if collide_range.size() > 0:
		collide_coords = collide_range[0]
		if self.coords != collide_coords - distance_increment: 
			move_helper(collide_coords - distance_increment, animation_sequence)
			return (self.coords - old_coords)
		else:
			return Vector2(0, 0)
	else:
		move_helper(self.coords + distance, animation_sequence)
		
		return distance



#the unit that calls this moves too, as part of the act of pushing
func push(distance, pusher=null):
	if dies_to_collision(pusher): #check if they're going to die from collision
		#print("deleting self")
		delete_self()
		get_node("/root/AnimationQueue").enqueue(self, "animate_delete_self", false)
	
	else:
		var distance_length = self.grid.hex_length(distance)
		var direction = self.grid.get_direction_from_vector(distance)
		var collide_range = self.grid.get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
		#if there's something in front, push that
		if collide_range.size() > 0:
			#print("found collido")
			var collide_coords = collide_range[0]
			#print(collide_coords)
			var location = self.grid.locations[collide_coords]
			var difference = (location.get_pos() - get_pos()) - Vector2(0, 80)
			#print(difference)
			var collide_pos = get_pos() + difference 
			var new_distance = (self.coords + distance) - collide_coords + self.grid.hex_normalize(distance)
			#print("new_distance is" + str(new_distance))
			get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [collide_pos, 300, true]) #push up against it
			self.grid.pieces[collide_coords].push(new_distance, self)

		move_or_fall_off(distance, pusher)


func move_or_fall_off(distance, pusher):
	if self.grid.locations.has(self.coords + distance):
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords + distance, 300, false])
		set_coords(self.coords + distance)
	else:
		delete_self()
		var distance_length = self.grid.hex_length(distance)
		var direction = self.grid.get_direction_from_vector(distance)
		var falloff_range = self.grid.get_range(self.coords, [1, distance_length + 1], null, false, [direction, direction + 1])
		var fall_off_pos = get_pos()
		if falloff_range.size() != 0:
			#print("caught the fall_off new check")
			var fall_off_coords = falloff_range[falloff_range.size() - 1]
			fall_off_pos = self.grid.locations[fall_off_coords].get_pos() 
			#var fall_off_distance = 30 * (fall_off_pos - get_pos()).normalized()
			get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [fall_off_pos, 300, true])
		get_node("/root/AnimationQueue").enqueue(self, "animate_delete_self", false)

		if self.side == "ENEMY" and self.grid.hex_normalize(distance) == Vector2(0, 1):
				emit_signal("broke_defenses")
			
func dies_to_collision(pusher):
	return false
	


	