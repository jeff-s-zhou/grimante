extends "res://Piece.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.side = "KING"
	
func set_coords(new_coords):
	get_parent().move_piece(self.coords, new_coords)
	self.coords = new_coords
	
func update():
	var movement_range = get_parent().get_location_range(self.coords, [1, 2])
	var valid_range = []
	for coords in movement_range:
		var capture_check_range = get_parent().get_range(coords, [1, 2], "PLAYER")
		if capture_check_range == []:
			valid_range.append(coords)
	
	if valid_range == []:
		print("PLAYER WINS")
	else:
		var selector = randi() % valid_range.size()
		act(valid_range[selector])
	
func act(coords):
	if !get_parent().pieces.has(coords):
		get_node("/root/AnimationQueue").enqueue(self, "animate_move", true, [coords, 300, true])
		set_coords(coords)
	elif get_parent().pieces[coords].side == "ENEMY":
		jump_swap(coords)
	elif get_parent().pieces[coords].side == "PLAYER":
		move(coords - self.coords)

func jump_swap(coords):
	var other_enemy_piece = get_parent().pieces[coords]
	get_node("/root/AnimationQueue").enqueue(other_enemy_piece, "animate_move", false, [self.coords, 300, false])
	get_node("/root/AnimationQueue").enqueue(self, "animate_move", false, [coords, 300, false])
	get_node("/root/AnimationQueue").enqueue(self, "animate_jump", true, [self.coords, coords])
	get_parent().swap_pieces(self.coords, coords)
	var temp = self.coords
	self.coords = coords
	other_enemy_piece.coords = temp
	
	

func animate_jump(old_coords, new_coords):
	#self.mid_leaping_animation = true
	set_z(3)
	var old_location = get_parent().locations[old_coords]
	var location = get_parent().locations[new_coords]
	var new_position = location.get_pos()
	var distance = old_location.get_pos().distance_to(new_position)
	var time = distance/250
	var old_position = Vector2(0, 0)
	var new_position = Vector2(0, -60)
	
	get_node("Tween2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), new_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	
	get_node("Tween2").interpolate_property(get_node("Physicals"), "transform/pos", \
		get_node("Physicals").get_pos(), old_position, time/2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween2").start()
	yield(get_node("Tween2"), "tween_complete")
	set_z(0)
	#self.mid_leaping_animation = false
	emit_signal("animation_done")


func input_event(event):
	pass
#	if event.is_action("select"):
#		if event.is_pressed():
#			get_parent().set_target(self)


func hover_highlight():
	pass
#	get_node("Timer").set_wait_time(0.01)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")


#	if self.action_highlighted:
#		get_node("Physicals/EnemyOverlays/White").show()
#		if get_parent().selected != null:
#			get_parent().selected.predict(self.coords)

func debug():
	pass
	#get_node("DebugText").show()
#	get_node("DebugText").set_text(str(self.coords))
	
	
func hover_unhighlight():
	pass
#	get_node("Physicals/EnemyOverlays/White").hide()
#	if self.action_highlighted:
#		if get_parent().selected != null:
#			get_parent().reset_prediction()

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	pass
#	self.action_highlighted = true
#	get_node("Physicals/EnemyOverlays/Red").show()

#called from grid to reset highlighting over the whole board
func reset_highlight(right_click_flag=false):
	pass
#	self.action_highlighted = false
#	get_node("Physicals/EnemyOverlays/White").hide()
#	
#	get_node("Physicals/EnemyOverlays/Orange").hide()
#	#reset_prediction_flyover() #it's this one lol
#	
#	get_node("Physicals/EnemyOverlays/Red").hide()


func reset_prediction_highlight():
	pass
#	reset_prediction_flyover()
#	get_node("Physicals/EnemyOverlays/Orange").hide()
#	if self.action_highlighted:
#		get_node("Physicals/EnemyOverlays/Red").show()
	


func attack_highlight():
	pass
#	self.action_highlighted = true
#	get_node("Physicals/EnemyOverlays/Red").show()

#the unit that calls this moves too, as part of the act of pushing

#need to override being pushed by other enemies so that the enemy that pushes it just moves in front of it

#need to have its own phase where it moves by an AI
#own AI first has to consider all valid moves, which should be fine because there's only 6 max
#either swap with other enemy, kill a player, or move to an empty space
#should try to move as far away from players as possible

#I think one problem is that if a player piece tries to check if it can damage, it just sees if it's an enemy
#we can either override the damage function so that it doesn't do anything
#or we can set it to a different side, KING

#need to have a check at the end of its own phase to see if it's adjacent to an enemy and can't move anywhere


#so we establish that the win condition check is at the end of the king's own phase, right?