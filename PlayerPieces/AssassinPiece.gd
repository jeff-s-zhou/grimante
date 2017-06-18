
extends "PlayerPiece.gd"

const DEFAULT_BACKSTAB_DAMAGE = 2
const ISOLATION_BONUS = 2
const DEFAULT_PASSIVE_DAMAGE = 1
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_ARMOR_VALUE = 3
const UNIT_TYPE = "Assassin"

const ATTACK_DESCRIPTION = ["""
"""]

const PASSIVE_DESCRIPTION = ["""
"""]

const BEHIND = Vector2(0, -1)

var backstab_damage = DEFAULT_BACKSTAB_DAMAGE setget , get_backstab_damage
var passive_damage = DEFAULT_PASSIVE_DAMAGE setget , get_passive_damage

var pathed_range

var bloodlust_flag = false

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.attack

func delete_self():
	get_node("/root/Combat").assassin = null
	.delete_self()

func queue_free():
	get_node("/root/Combat").assassin = null
	.queue_free()

func resurrect():
	get_node("/root/Combat").assassin = self
	.resurrect()


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
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	subtract_anim_count()
	
func animate_directly_below_backstab(attack_coords):
	add_anim_count()
	var attack_location = get_parent().locations[attack_coords]
	var difference = 3 * (attack_location.get_pos() - get_pos())/4
	var attack_position = attack_location.get_pos() - difference
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	subtract_anim_count()


#parameters to use for get_node("get_parent()").get_neighbors
func display_action_range():
	var action_range = get_attack_range() + get_movement_range()
	for coords in action_range:
		get_parent().get_at_location(coords).movement_highlight()
	.display_action_range()
	

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
		if self.bloodlust_flag:
			soft_placed() #in the case that it resets again using its passive
		else:
			placed()
	elif _is_within_attack_range(new_coords):
		handle_pre_assisted()
		#get_node("/root/Combat").display_overlay(self.unit_name)
		backstab(new_coords)
	else:
		invalid_move()


func backstab(new_coords):
	if new_coords == self.coords + Vector2(0, 1):
		add_animation(self, "animate_directly_below_backstab", true, [new_coords])
	else:
		add_animation(self, "animate_backstab", true, [new_coords])
	var action = get_new_action(false)
	action.add_call("attacked", [self.get_backstab_damage(new_coords)], new_coords)
	action.execute()
	var return_position = get_parent().locations[new_coords + BEHIND].get_pos()
	add_animation(self, "animate_move_to_pos", true, [return_position, 200, true])
	set_coords(new_coords + BEHIND)
		
	if !self.bloodlust_flag: #hasn't triggered bloodlust yet
		if get_parent().pieces.has(new_coords): #if it didn't kill
			soft_placed()
		else:
			add_animation(self, "emit_animated_placed", false)
			activate_bloodlust()
	
	else: #already triggered bloodlust
		placed()

func activate_bloodlust():
	self.handle_assist()
	self.bloodlust_flag = true
	get_parent().selected = null

#neede for tutorials
func emit_animated_placed():
	emit_signal("animated_placed")

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		get_parent().pieces[new_coords].predict(self.get_backstab_damage(new_coords))

func cast_ultimate():
	get_node("Physicals/OverlayLayers/UltimateWhite").show()
	self.ultimate_flag = true
	get_parent().reset_highlighting()
	display_action_range()
	
	
#same as regular placed() except doesn't reset the ultimate_flag or bloodlust_flag
func soft_placed(): 
	self.handle_assist()
	add_animation(self, "animate_placed", false)
	self.state = States.PLACED
	get_parent().selected = null


#resets the assassin to be able to act again
func unplaced():
	self.state = States.DEFAULT
	add_animation(self, "animate_unplaced", false)
	
func animate_unplaced():
	get_node("Physicals/AnimatedSprite").play("default")
	
func finisher_reactivate():
	self.bloodlust_flag = false
	.finisher_reactivate()

func placed(ending_turn=false):
	self.bloodlust_flag = false
	.placed(ending_turn)


func trigger_passive(attack_range):
	for attack_coords in attack_range:
		if _is_within_passive_range(attack_coords):
			add_animation(self, "animate_passive", true, [attack_coords])
			var action = get_new_action(false)
			action.add_call("opportunity_attacked", [self.passive_damage], attack_coords)
			action.execute()
	
			if !get_parent().pieces.has(attack_coords) and !self.bloodlust_flag and self.state == States.PLACED:
				activate_bloodlust()
				unplaced()
			add_animation(self, "animate_passive_end", true, [self.coords])


func animate_passive(attack_coords):
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, true, Tween.TRANS_SINE, Tween.EASE_IN)

func animate_passive_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)