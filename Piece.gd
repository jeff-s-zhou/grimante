extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var side = null

signal animation_done

var mid_animation = false

var mid_leaping_animation = false

var stunned = false

var unit_name


func _ready():
	get_node("CollisionArea").connect("area_enter", self, "collide")
	get_node("CollisionArea").connect("area_exit", self, "uncollide")


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
	if self.mid_animation and !self.mid_leaping_animation: #If leaping, it'll set its own z above everythin else
		print("this is the one moving: " + self.side )
		var other_piece = area.get_parent()
		print(other_piece)
		if other_piece.get_pos().y > get_pos().y:
			other_piece.set_z(get_z() + 1)
		else:
			other_piece.set_z(get_z() - 1)
	
func uncollide(area):
	if area.get_name() != "CursorArea": #make sure it's not the thing that checks for mouse inside areas
		if self.mid_animation:
			var other_piece = area.get_parent()
			other_piece.set_z(0)
		

func set_mid_animation(flag):
	self.mid_animation = flag

func animate_summon():
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
func animate_delete_self(blocking=true):
	get_node("Tween").interpolate_property(self, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	if blocking:
		emit_signal("animation_done")
	self.queue_free()
	
func animate_move_to_pos(position, speed, blocking=false, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var distance = get_pos().distance_to(position)
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, trans_type, ease_type)
	get_node("Tween").start()
	if blocking:
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")
	

func animate_move(new_coords, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed, false, trans_type, ease_type)
	if(blocking):
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")

#the unit that calls this moves too, as part of the act of pushing
func push(distance, pusher=null):
	if self.unit_name != null:
		print("pushing type: " + self.unit_name)
	if dies_to_collision(pusher): #check if they're going to die from collision
		print("deleting self")
		delete_self()
		get_node("/root/AnimationQueue").enqueue(self, "animate_delete_self", true)
	
	else:
		var distance_length = get_parent().hex_length(distance)
		var direction = get_parent().get_direction_from_vector(distance)
		var collide_range = get_parent().get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
		#if there's something in front, push that
		if collide_range.size() > 0:
			print("found collido")
			var collide_coords = collide_range[0]
			print(collide_coords)
			var location = get_parent().locations[collide_coords]
			var difference = (location.get_pos() - get_pos())/4
			print(difference)
			var collide_pos = get_pos() + difference 
			var new_distance = (self.coords + distance) - collide_coords + get_parent().hex_normalize(distance)
			print("new_distance is" + str(new_distance))
			get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [collide_pos, 250, true]) #push up against it
			get_parent().pieces[collide_coords].push(new_distance, self)
		
		move_or_fall_off(distance)


func move_or_fall_off(distance):
	if get_parent().locations.has(self.coords + distance):
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords + distance, 250, false])
		set_coords(self.coords + distance)
	else:
		delete_self()
		var distance_length = get_parent().hex_length(distance)
		var direction = get_parent().get_direction_from_vector(distance)
		var falloff_range = get_parent().get_range(self.coords, [1, distance_length + 1], null, false, [direction, direction + 1])
		var fall_off_pos = get_pos()
		if falloff_range.size() != 0:
			print("caught the fall_off new check")
			var fall_off_coords = falloff_range[falloff_range.size() - 1]
			fall_off_pos = get_parent().locations[fall_off_coords].get_pos() 
			#var fall_off_distance = 30 * (fall_off_pos - get_pos()).normalized()
			get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [fall_off_pos, 250, true])
		get_node("/root/AnimationQueue").enqueue(self, "animate_delete_self", false)

		if self.side == "ENEMY" and get_parent().hex_normalize(distance) == Vector2(0, 1):
				emit_signal("broke_defenses")
			
func dies_to_collision(pusher):
	return false
	