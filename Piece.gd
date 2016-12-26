extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func animate_summon():
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	
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
	animate_move_to_pos(new_position, speed, trans_type, ease_type)
	if(blocking):
		yield(get_node("Tween"), "tween_complete")
		emit_signal("animation_done")


func push(distance, is_knight=false):
	if get_parent().locations.has(self.coords + distance):
		var distance_length = distance.length()
		var collide_range = get_parent().get_range(self.coords, [1, distance_length + 1], "ANY", true, [3, 4])
		#if there's something in front, push that
		if collide_range.size() > 0:
			var collide_coords = collide_range[0]
			var location = get_parent().locations[collide_coords]
			var collide_pos = location.get_pos() + Vector2(0, -93) #offset it so that it "taps" it
			var new_distance = (self.coords + distance) - collide_coords + Vector2(0, 1)
			print("new_distance is" + str(new_distance))
			get_node("/root/AnimationQueue").enqueue(self, "animate_move", true, [collide_pos, 250])
			get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords + distance, 250, false])
			get_parent().pieces[collide_coords].push(new_distance)
		else:
			get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [self.coords + distance, 250, false])
		set_coords(self.coords + distance)
	else:
		#TODO: move to last square before falling off the map
		delete_self()
		get_node("/root/AnimationQueue").enqueue(self, "animate_delete_self", false)