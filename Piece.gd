extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var side = null

func animate_summon():
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
func animate_move_to_pos(position, speed, blocking=false, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var distance = get_pos().distance_to(position)
	get_node("Tween").interpolate_property(self, "transform/pos", get_pos(), position, distance/speed, trans_type, ease_type)
	get_node("Tween").start()
	if blocking:
		print("blocking move_to_pos")
		yield(get_node("Tween"), "tween_complete")
		print("move_to_pos done")
		emit_signal("animation_done")
	

func animate_move(new_coords, speed=250, blocking=true, trans_type=Tween.TRANS_LINEAR, ease_type=Tween.EASE_IN):
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, speed, false, trans_type, ease_type)
	if(blocking):
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")

#the unit that calls this moves too, as part of the act of pushing
func push(distance, side=null):
	if dies_to_collision(side): #check if they're going to die from collision
		print("deleting self")
		delete_self()
		get_node("/root/AnimationQueue").enqueue(self, "animate_delete_self", false)
	
	elif get_parent().locations.has(self.coords + distance):
		print("not deleting self")
		var distance_length = distance.length()
		print(distance)
		var direction = get_parent().get_direction_from_vector(distance)
		print(direction)
		var collide_range = get_parent().get_range(self.coords, [1, distance_length + 1], "ANY", true, [direction, direction + 1])
		#if there's something in front, push that
		if collide_range.size() > 0:
			print("found collido")
			var collide_coords = collide_range[0]
			print(collide_coords)
			var location = get_parent().locations[collide_coords]
			var difference = (location.get_pos() - get_pos())/3
			print(difference)
			var collide_pos = get_pos() + difference #offset it so that it "taps" it #TODO fix this
			var new_distance = (self.coords + distance) - collide_coords + get_parent().hex_normalize(distance)
			print("new_distance is" + str(new_distance))
			get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [collide_pos, 250, true])
			get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords + distance, 250, false])
			get_parent().pieces[collide_coords].push(new_distance, self.side)
		else:
			get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords + distance, 250, false])
		set_coords(self.coords + distance)
	else:
		print("actually deleting self lul")
		#TODO: move to last square before falling off the map
		delete_self()
		get_node("/root/AnimationQueue").enqueue(self, "animate_delete_self", false)
		
func dies_to_collision(side_of_pusher):
	return false
	