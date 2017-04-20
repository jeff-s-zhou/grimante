
extends "PlayerPiece.gd"

const DEFAULT_BACKSTAB_DAMAGE = 2
const BLOODLUST_BONUS = 2
const DEFAULT_PASSIVE_DAMAGE = 1
const DEFAULT_MOVEMENT_VALUE = 2
const DEFAULT_ARMOR_VALUE = 3
const UNIT_TYPE = "Assassin"
const OVERVIEW_DESCRIPTION = """3 Armor

Movement: 2 Range Step Move

Inspire: +1 Attack
"""

const ATTACK_DESCRIPTION = """Backstab. 2 range. Teleport behind an enemy and deal 2 damage. Will fail if there is a unit behind the enemy.
"""

const PASSIVE_DESCRIPTION = """Opportunity Strikes. If an adjacent enemy is attacked and isn't killed, the Assassin attacks it for 1 damage. Will trigger Bloodlust if the Assassin is already on cooldown.

Bloodlust. If the Assassin kills a unit, it may act again and its next Backstab deals +2 damage. May only activate once per turn."""

const ULTIMATE_DESCRIPTION = """Danse Macabre. Requires and spends 3 Combo Points. During this Player Phase, the Assassin gains +2 damage and can act again if it kills an enemy. Can be used any number of times per level. 
"""

const BEHIND = Vector2(0, -1)

var backstab_damage = DEFAULT_BACKSTAB_DAMAGE setget , get_backstab_damage
var passive_damage = DEFAULT_PASSIVE_DAMAGE setget , get_passive_damage

var pathed_range

var bloodlust_flag = false

func _ready():
	set_armor(DEFAULT_ARMOR_VALUE)
	self.movement_value = DEFAULT_MOVEMENT_VALUE
	self.unit_name = UNIT_TYPE
	self.overview_description = OVERVIEW_DESCRIPTION
	self.attack_description = ATTACK_DESCRIPTION
	self.passive_description = PASSIVE_DESCRIPTION
	self.ultimate_description = ULTIMATE_DESCRIPTION
	self.assist_type = ASSIST_TYPES.attack

func delete_self(animation_sequence=null):
	get_node("/root/Combat").assassin = null
	.delete_self(animation_sequence)


func get_backstab_damage():
	if self.bloodlust_flag:
		return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_BACKSTAB_DAMAGE + BLOODLUST_BONUS
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_BACKSTAB_DAMAGE
	
func get_passive_damage():
	return get_assist_bonus_attack() + self.attack_bonus + DEFAULT_PASSIVE_DAMAGE


func get_movement_range():
	self.pathed_range = get_parent().get_pathed_range(self.coords, self.movement_value)
	return self.pathed_range.keys()
	
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
	var difference = 2 * (attack_location.get_pos() - get_pos())/3
	var attack_position = attack_location.get_pos() - difference
	
	get_node("Tween 2").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(get_node("AssassinFade"), "visibility/opacity", 1, 0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween 2").start()
	animate_move_to_pos(attack_position, 200, true, Tween.TRANS_SINE, Tween.EASE_IN)
	subtract_anim_count()
	
func animate_directly_below_backstab(attack_coords):
	add_anim_count()
	var attack_location = get_parent().locations[attack_coords]
	var difference = 2 * (attack_location.get_pos() - get_pos())/3
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
		var args = [self.coords, new_coords, self.pathed_range, 350]
		get_node("/root/AnimationQueue").enqueue(self, "animate_stepped_move", true, args)
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
		get_node("/root/AnimationQueue").enqueue(self, "animate_directly_below_backstab", true, [new_coords])
	else:
		get_node("/root/AnimationQueue").enqueue(self, "animate_backstab", true, [new_coords])
	#TODO: yield to AnimationQueue call
	var action = get_new_action(new_coords, false)
	action.add_call("opportunity_attacked", [self.backstab_damage])
	action.execute()
	var return_position = get_parent().locations[new_coords + BEHIND].get_pos()
	get_node("/root/AnimationQueue").enqueue(self, "animate_move_to_pos", true, [return_position, 200, true])
	set_coords(new_coords + BEHIND)
		
	if !self.bloodlust_flag: #hasn't triggered bloodlust yet
		if get_parent().pieces.has(new_coords): #if it didn't kill
			soft_placed()
		else:
			activate_bloodlust()
	
	else: #already triggered bloodlust
		placed()

func activate_bloodlust():
	self.handle_assist()
	self.bloodlust_flag = true
	get_parent().selected = null

func predict(new_coords):
	if _is_within_attack_range(new_coords):
		get_parent().pieces[new_coords].predict(self.backstab_damage)

func cast_ultimate():
	get_node("Physicals/OverlayLayers/UltimateWhite").show()
	self.ultimate_flag = true
	get_parent().reset_highlighting()
	display_action_range()
	
	
#same as regular placed() except doesn't reset the ultimate_flag or bloodlust_flag
func soft_placed(): 
	self.handle_assist()
	get_node("/root/AnimationQueue").enqueue(self, "animate_placed", false)
	self.state = States.PLACED
	get_parent().selected = null


#resets the assassin to be able to act again
func unplaced():
	self.state = States.DEFAULT
	get_node("/root/AnimationQueue").enqueue(self, "animate_unplaced", false)
	
func animate_unplaced():
	get_node("Physicals/AnimatedSprite").play("default")
	

func placed():
	self.bloodlust_flag = false
	if self.ultimate_flag:
		self.ultimate_flag = false
	.placed()

func trigger_passive(attack_range):
	for attack_coords in attack_range:
		if _is_within_passive_range(attack_coords):
			get_node("/root/AnimationQueue").enqueue(self, "animate_passive", true, [attack_coords])
			var action = get_new_action(attack_coords, false)
			action.add_call("opportunity_attacked", [self.passive_damage])
			action.execute()
	
			if !get_parent().pieces.has(attack_coords) and !self.bloodlust_flag and self.state == States.PLACED:
				activate_bloodlust()
				unplaced()
			get_node("/root/AnimationQueue").enqueue(self, "animate_passive_end", true, [self.coords])


func animate_passive(attack_coords):
	var location = get_parent().locations[attack_coords]
	var difference = 2 * (location.get_pos() - get_pos())/3
	var new_position = location.get_pos() - difference
	animate_move_to_pos(new_position, 450, true, Tween.TRANS_SINE, Tween.EASE_IN)

func animate_passive_end(original_coords):
	var location = get_parent().locations[original_coords]
	var new_position = location.get_pos()
	animate_move_to_pos(new_position, 300, true)