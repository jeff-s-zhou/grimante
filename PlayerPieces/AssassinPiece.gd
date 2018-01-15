
extends "PlayerPiece.gd"

const DEFAULT_BACKSTAB_DAMAGE = 1
const ISOLATION_BONUS = 2
const DEFAULT_PASSIVE_DAMAGE = 1
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_SHIELD = false
const UNIT_TYPE = "Assassin"

const CLONE_PROTOTYPE = preload("res://PlayerPieces/Components/AssassinClone.tscn")

const BEHIND = Vector2(0, -1)

var backstab_damage = DEFAULT_BACKSTAB_DAMAGE setget , get_backstab_damage
var passive_damage = DEFAULT_PASSIVE_DAMAGE setget , get_passive_damage

var pathed_range

func _ready():
	set_shield(DEFAULT_SHIELD)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	load_description(self.unit_name)
	self.assist_type = ASSIST_TYPES.attack

func delete_self(isolated_call=true, delay=0.0):
	get_parent().assassin = null
	.delete_self(isolated_call, delay)

func queue_free():
	get_parent().assassin = null
	.queue_free()

func resurrect(coords):
	get_parent().assassin = self
	.resurrect(coords)


func get_backstab_damage(coords):
	var neighbor_coords_range = get_parent().get_range(coords, [1,2], "ENEMY")
	if neighbor_coords_range == []:
		return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_BACKSTAB_DAMAGE + ISOLATION_BONUS
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_BACKSTAB_DAMAGE
	
func get_passive_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_PASSIVE_DAMAGE


func get_movement_range():
	return get_parent().get_radial_range(self.coords, [1, self.movement_value])
	
	
func get_attack_range():
	var unfiltered_range = get_parent().get_radial_range(self.coords, [1, self.movement_value], "ENEMY")
	var attack_range = []
	var directly_below_coords = self.coords + Vector2(0, 1)
	if (directly_below_coords in unfiltered_range): #catch the piece immediately below the assassin
		attack_range.append(directly_below_coords)
	for coords in unfiltered_range:
		if get_parent().locations.has(coords + BEHIND) and !get_parent().pieces.has(coords + BEHIND): #only return enemies with their backs open
			attack_range.append(coords)
			
	return attack_range
	
func get_passive_range():
	return get_parent().get_radial_range(self.coords, [1, 1], "ENEMY")

#calls animate_move_to_pos as the last part of sequence
#animate_move_to_pos is what emits the required signals
func animate_backstab(attack_coords):
	add_anim_count()
	var position_coords = attack_coords + BEHIND

	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 1, 0, 0.7, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("AssassinFade"), "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	yield(get_node("Tween 2"), "tween_complete")
	yield(get_node("Tween 2"), "tween_complete")
	var location = get_parent().locations[position_coords]
	var new_position = location.get_pos()
	set_pos(new_position)
	
	var attack_location = get_parent().locations[attack_coords]
	var difference = 3 * (attack_location.get_pos() - get_pos())/4
	var attack_position = attack_location.get_pos() - difference
	
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("AssassinFade"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	animate_move_to_pos(attack_position, 300, true, Tween.TRANS_QUAD, Tween.EASE_IN)
	subtract_anim_count()


func animate_directly_below_backstab(attack_coords):
	add_anim_count()
	var attack_location = get_parent().locations[attack_coords]
	var difference = 3 * (attack_location.get_pos() - get_pos())/4
	var attack_position = attack_location.get_pos() - difference
	animate_move_to_pos(attack_position, 300, true, Tween.TRANS_QUAD, Tween.EASE_IN)
	subtract_anim_count()


func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()


func _is_within_attack_range(new_coords):
	var attack_range = get_attack_range()
	return new_coords in attack_range
	
func _is_within_movement_range(new_coords):
	return new_coords in get_movement_range()
	
func _is_within_passive_range(new_coords):
	return new_coords in get_passive_range()


func act(new_coords):
	if _is_within_movement_range(new_coords):
		handle_pre_assisted()
		var args = [new_coords, 350, true]
		add_animation(self, "animate_move_and_hop", true, args)
		set_coords(new_coords)
		placed()
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		#get_node("/root/Combat").display_overlay(self.unit_name)
		backstab(new_coords)
		check_for_traps()
		
	else:
		invalid_move()


func backstab(new_coords):
	if new_coords == self.coords + Vector2(0, 1):
		add_animation(self, "animate_directly_below_backstab", true, [new_coords])
	else:
		add_animation(self, "animate_backstab", true, [new_coords])
	set_coords(new_coords + BEHIND)
	var action = get_new_action()
	action.add_call("attacked", [self.get_backstab_damage(new_coords), self], new_coords)
	action.execute()
	var return_position = get_parent().locations[new_coords + BEHIND].get_pos()
	add_animation(self, "animate_move_to_pos", true, [return_position, 200, true])
		
	if get_parent().pieces.has(new_coords): #if it didn't kill
		placed()
	else:
		add_animation(self, "emit_animated_placed", false)
		self.grid.handle_field_of_lights(self)
		activate_bloodlust()
		


func activate_bloodlust():
	self.handle_assist()
	get_parent().selected = null

#not exactly sure why I need this now that I'm not emitting the signal for tutorial forced actions
func emit_animated_placed():
	get_node("AnimationPlayer").stop(true)
	animate_unglow()
	#emit_signal("animated_placed")

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		get_parent().pieces[new_coords].predict(self.get_backstab_damage(new_coords), self)


#resets the assassin to be able to act again
func unplaced():
	self.state = States.DEFAULT
	add_animation(self, "animate_reactivate", false)


func trigger_passive(attack_range):
	var passive_range = []
	for attack_coords in attack_range:
		if _is_within_passive_range(attack_coords):
			passive_range.append(attack_coords)
	
	
	if passive_range.size() > 0:
		var attack_coords = passive_range[0]
		passive_range.pop_front()
		#animate shadow targets
		for coords in passive_range:
			print('adding shadow passive animation')
			add_animation(self, "animate_shadow_passive", false, [coords])
		
		#animate direct target
		add_animation(self, "animate_passive", true, [attack_coords])
		var action = get_new_action(false)
		passive_range.append(attack_coords) #add all the coords back together again to deal damage
		action.add_call("attacked", [self.passive_damage, self], passive_range)
		action.execute()
		
		#if any of the passive attacks killed, trigger bloodlust
		for attack_coords in passive_range:
			if !get_parent().pieces.has(attack_coords) and self.state == States.PLACED:
				#activate_bloodlust()
				unplaced()
				break
				
		add_animation(self, "animate_passive_end", true, [self.coords])

func animate_shadow_passive(attack_coords):
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(0.5)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	print("animating shadow passive: ", attack_coords)
	var clone = CLONE_PROTOTYPE.instance()
	get_parent().add_child(clone)
	clone.set_pos(get_pos())
	
	var old_position = get_pos()
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	var speed = 450
	
	add_anim_count()
	var tween = Tween.new()
	add_child(tween)
	var distance = get_pos().distance_to(new_position)
	var dim_distance = dim_multi_distance(distance)
	tween.interpolate_property(clone, "transform/pos", clone.get_pos(), new_position, float(dim_distance)/450, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete")
	tween.interpolate_property(clone, "transform/pos", clone.get_pos(), old_position, float(dim_distance)/300, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(clone, "visibility/opacity", 0.6, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete")
	tween.queue_free()
	clone.queue_free()
	subtract_anim_count()



func animate_passive(attack_coords):
	print("attack coords in passive:", attack_coords)
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, true, Tween.TRANS_SINE, Tween.EASE_IN, 0.5)

func animate_passive_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)