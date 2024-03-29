
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

var locations = {}
var pieces = {}
var reinforcements = {}

var speed_up_rows = {}

var assassin = null
var saint = null
var stormdancer = null
var pyromancer = null

var deploying = false

const DEPLOY_TILES_5 = [Vector2(1, 6), Vector2(2, 6),
Vector2(3, 7), Vector2(4, 7), Vector2(5, 8)
]

const DEPLOY_TILES_4 = [Vector2(1, 6), Vector2(2, 6), Vector2(4, 7), Vector2(5, 8)]

var deploy_tiles = DEPLOY_TILES_5

#starts at 1, 2, 2, 3, 3, 4, 4, 5, 5,
#ends at 8, 8, 9, 9, 10, 10, 11, 11, 12

#in order, (0, 8), (1, 8), (1, 9), (2, 9), (2, 10), (3, 10), (3, 11), (4, 11), (4, 12)

var tiles_x = 7 #x
var tiles_y = 6 #y


#const TILE_X_OFFSET = -16
const TILE_X_OFFSET = -5
#const TILE_Y_OFFSET = 8
const TILE_Y_OFFSET = 20

const INITIAL_X = 50
const INITIAL_Y = 100


const _LOCATION_Y_OFFSETS = [0, 0, 1, 1, 2, 2, 3]

var selected = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("ReviveSelector").connect("selected", self, "delayed_revive")
	
	var location = load("res://Location.tscn")

	# place location tiles
	for i in range(0, self.tiles_x):
		var offset = 0
		var column_count = self.tiles_y 
		if i % 2 == 1:
			#offset = -44
			offset = -50
			column_count = self.tiles_y + 1
		for j in range(0, column_count):
			var location1 = location.instance()
			var tile_x_spacing = location1.get_size().width + TILE_X_OFFSET
			var tile_y_spacing = location1.get_size().height + TILE_Y_OFFSET
			location1.set_pos(Vector2(INITIAL_X + tile_x_spacing * i, INITIAL_Y + offset + (tile_y_spacing * j)))
			add_child(location1)
			
			if j == column_count - 1:
				location1.set_endzone()
			
			var location_y_coord = _LOCATION_Y_OFFSETS[i] + j
			locations[Vector2(i, location_y_coord)] = location1
			location1.set_coords(Vector2(i, location_y_coord))


func handle_revive(coords):
	var dead_heroes = get_tree().get_nodes_in_group("dead_heroes")
	if dead_heroes.size() == 1:
		dead_heroes[0].resurrect(coords)
		return true
	elif dead_heroes.size() > 1:
		get_node("ReviveSelector").handle(coords)
		return true
	return false
	

func delayed_revive(dead_hero, coords):
	dead_hero.resurrect(coords)


func clear_board():
	for piece in self.pieces.values():
		piece.queue_free()
	self.pieces = {}
	for location in self.locations.values():
		location.soft_reset()

func set_deploying(deploying_flag, flags={}):
	self.deploying = deploying_flag
	if deploying:
		for deploy_tile_coords in self.deploy_tiles:
			if self.locations.has(deploy_tile_coords):
				self.locations[deploy_tile_coords].set_deployable_indicator(true)
	else:
		reset_deployable_indicators()
		
	
func is_within_deploy_range(coords):
	return coords in self.deploy_tiles
	
	
func toggle_hex_diagonal_guide(flag, coords=null):
	if flag:
		var timer = Timer.new()
		add_child(timer)
		timer.set_wait_time(0.01)
		timer.start()
		yield(timer, "timeout")
		timer.queue_free()
		get_node("DiagonalGuide").set_pos(self.locations[coords].get_pos())
	#needed so it's not too fast and reset prediction is after prediction
	get_node("DiagonalGuide").set_hidden(!flag)
	#get_node("/root/AnimationQueue").enqueue(get_node("DiagonalGuide"), "set_hidden", false, [!flag])
	

func predict(coords):
	if !self.deploying and self.selected != null:
		self.selected.predict(coords)
		if self.selected.diagonal_guide_prediction_flag:
			toggle_hex_diagonal_guide(true, coords)
	
func initialize(flags):
	if flags.has("hide_indirect_highlighting"):
		for location in self.locations.values():
			location.hide_indirect_highlighting()
		

func debug():
	for key in self.locations.keys():
		self.locations[key].debug()
		
func display_coords():
	for key in self.locations.keys():
		self.locations[key].debug()

#so we know what target
func set_target(target):
	if self.selected != null:
		self.selected.select_action_target(target)
		return true
	return false
		
		
func set_reinforcement(coords, enemy_piece):
	self.reinforcements[coords] = true
	self.locations[coords].set_reinforcement(enemy_piece)
	


func handle_incoming(first=false):
	var animation_speed = 0.9
	for coords in self.reinforcements.keys():
		self.locations[coords].deploy_enemy(animation_speed, first)
		animation_speed -= (animation_speed * 0.15)
	self.reinforcements = {}
		
func display_incoming():
	for location in self.locations.values():
		location.display_incoming()

#child_free is when the saint and crusader swap locations
func add_piece(coords, piece, child_free=false):
	
	self.pieces[coords] = piece
	self.locations[coords].set_pickable(false)
	piece.coords = coords
	var location = self.locations[coords]
	
	if !child_free:
		add_child(piece)

	if piece.unit_name == "Assassin":
		self.assassin = piece
	elif piece.unit_name == "Saint":
		self.saint = piece
	elif piece.unit_name == "Stormdancer":
		self.stormdancer = piece
	elif piece.unit_name == "Pyromancer":
		self.pyromancer = piece
	
	piece.set_global_pos(location.get_global_pos())
	piece.added_to_grid()
	get_node("/root/AnimationQueue").enqueue(piece, "animate_summon", false)
	#piece.animate_summon()
	
		
func handle_assassin_passive(attack_range, caller):
	if self.assassin != null and caller != self.assassin:
		self.assassin.trigger_passive(attack_range)
		
func handle_lightning(attack_range, caller):
	if self.stormdancer != null:
		self.stormdancer.handle_lightning(attack_range)

		
func handle_field_of_lights(hero):
	print("handling field of lights")
	if self.saint != null and hero != saint:
		self.saint.handle_field_of_lights(hero)
	elif hero == saint:
		self.saint.self_handle_field_of_lights()
		
		
func handle_enemy_death(coords):
	if self.pyromancer != null:
		self.pyromancer.gather_charges(coords)
		
		
func clear_animations():
	for coords in self.speed_up_rows.values():
		print("clearing coords: ", coords)
		self.speed_up_rows.erase(coords.x)
		get_node("FieldEffects").clear_speed_up(coords)

func animate_speed_up(coords):
	#if a griffin is already in the row and it's above this one (or it is this one), no need to speed up
	if coords.x in self.speed_up_rows and coords.y >= self.speed_up_rows[coords.x].y:
		return
	
	#if we're the top griffin in the row, we cast the animation from here
	self.speed_up_rows[coords.x] = coords
	get_node("FieldEffects").emit_speed_up(coords)


func animate_clear_speed_up(coords):
	if coords.x in self.speed_up_rows and coords.y == self.speed_up_rows[coords.x].y:
		self.speed_up_rows.erase(coords.x)
		get_node("FieldEffects").clear_speed_up(coords)


func remove_piece(coords):
	self.pieces[coords].set_pickable(false)
	self.pieces.erase(coords)
	locations[coords].set_pickable(true)

#called from playerpiece's select to make prediction simpler
#(that way we don't have to ignore the playerpiece when figuring out pathing)
func temp_remove_piece(coords):
	self.pieces.erase(coords)
	
func temp_add_piece(coords, piece):
	self.pieces[coords] = piece
	


func swap_pieces(coords1, coords2):
	if deploying:
		deploy_swap_pieces(coords1, coords2)
	else:
		var temp = self.pieces[coords1]
		self.pieces[coords1] = self.pieces[coords2]
		self.pieces[coords2] = temp


func deploy_swap_pieces(coords1, coords2):
	var temp = self.get_piece(coords1)
	self.set_piece(coords1, self.get_piece(coords2))
	self.set_piece(coords2, temp)


func get_location(coords):
	return self.locations[coords]

func has_piece(coords):
	return self.pieces.has(coords)
	
func has_enemy(coords):
	return self.pieces.has(coords) and self.pieces[coords].side == "ENEMY"
	
func has_ally(coords):
	return self.pieces.has(coords) and self.pieces[coords].side == "PLAYER"

func set_piece(coords, piece):
	self.pieces[coords] = piece

func get_piece(coords):
	return self.pieces[coords]
	

func erase_piece(coords):
	self.pieces.erase(coords)
	
#moves the piece's location on grid. doesn't actually physically move the sprite
func move_piece(old_coords, new_coords):
	locations[old_coords].set_pickable(true)
	var piece = pieces[old_coords]
	pieces.erase(old_coords)
	pieces[new_coords] = piece
	locations[new_coords].set_pickable(false)

#only returns a free location
func get_free_location_at(coords):
	if pieces.has(coords):
		return null
	return locations[coords]
	

#will return a piece if there is a piece, otherwise the location
func get_at_location(coords):
	if pieces.has(coords):
		return pieces[coords]
	elif locations.has(coords):
		return locations[coords]
	else:
		return null


func reset_deployable_indicators():
	for location in locations.values():
		location.set_deployable_indicator(false)


func set_selected(piece):
	self.selected = piece
	temp_remove_piece(piece.coords) #for easier prediction


#acting is so we know when to properly unglow animations in PlayerPiece
#if acting is true, then we don't unglow
func deselect(acting=false):
	if self.selected != null:
		self.selected.deselect(acting)
		temp_add_piece(self.selected.coords, self.selected) #because we removed it for easier prediction
		self.selected = null
		self.clear_display_state(true)
		get_parent().check_hovered()

#in this case we always need to make sure there's no highlighting, even when hovered
func end_turn_clear_state():
	if self.selected != null:
		self.selected.deselect(false)
		temp_add_piece(self.selected.coords, self.selected) #because we removed it for easier prediction
		self.selected = null
	self.clear_display_state(true)

func focus_coords(select_coords, target_coords):
	for location in locations.values():
		location.set_targetable(false)
	for piece in pieces.values():
		piece.set_targetable(false)
	
	if pieces.has(select_coords):
		pieces[select_coords].set_targetable(true)
		
	if pieces.has(target_coords):
		pieces[target_coords].set_targetable(true)
	elif locations.has(target_coords):
		locations[target_coords].set_targetable(true)

func unfocus():
	for location in locations.values():
		location.set_targetable(true)
	for piece in pieces.values():
		piece.set_targetable(true)
		

func set_revive_tiles(flag):
	if flag and get_tree().get_nodes_in_group("dead_heroes").size() > 0:
		for piece in self.pieces.values():
			if !piece.is_enemy():
				var revive_range = get_range(piece.coords) 
				for coords in revive_range:
					self.locations[coords].set_revivable(true)
	else:
		for location in self.locations.values():
			location.set_revivable(false)


#done once a piece is moved by the player	
#right click flag is so if we know to check immediately after if cursor is still in a piece's area
#and apparently so we know to clear flyovers...lol
func clear_display_state(right_click_flag=false):
	toggle_hex_diagonal_guide(false)
	get_node("DottedLine").hide()
	for location in locations.values():
		location.reset_highlight()
	for piece in pieces.values():
		piece.clear_display_state()


#called when moved off of a tile while a player unit is selected
func reset_prediction():
	if !self.deploying:
		if self.selected != null:	
			if self.selected.diagonal_guide_prediction_flag:
				toggle_hex_diagonal_guide(false)
			for piece in pieces.values():
				piece.reset_prediction_highlight()
		else:
			clear_display_state()


func get_line_range(coords, direction_vector, side=null, magnitude_range=[1, 8]):
	var return_set = []
	var normalized_vector = hex_normalize(direction_vector)
	for i in range(magnitude_range[0], magnitude_range[1]):
		var new_coords = coords + Vector2(normalized_vector.x * i, normalized_vector.y * i)
		if self.locations.has(new_coords):
			if side == null:
				return_set.append(new_coords)
			elif side != null and self.pieces.has(new_coords):
				if self.pieces[new_coords].side == side:
					return_set.append(new_coords)
				else:
					break #if the sides are different, stop the line
	return return_set


func get_location_range(coords, magnitude_range=[1, 2], direction_range = [0, 6]):
	var return_set = [] #make this a dict?
	var change_vector = Vector2(0, 0)
	for direction in range(direction_range[0], direction_range[1]):
		for magnitude in range(magnitude_range[0], magnitude_range[1]):
			if direction == 0:
				change_vector = Vector2(0, -1)
			elif direction == 1:
				change_vector = Vector2(1, 0)
			elif direction == 2:
				change_vector = Vector2(1, 1)
			elif direction == 3:
				change_vector = Vector2(0, 1)
			elif direction == 4:
				change_vector = Vector2(-1, 0)
			elif direction == 5:
				change_vector = Vector2(-1, -1)
				
			if self.locations.has(coords + change_vector * magnitude):
				return_set.append(coords + change_vector * magnitude)
	return return_set
	
func get_change_vector(direction):
	if direction < 0:
		direction = direction + 6
	var change_vector = null
	if direction == 0:
		change_vector = Vector2(0, -1)
	elif direction == 1:
		change_vector = Vector2(1, 0)
	elif direction == 2:
		change_vector = Vector2(1, 1)
	elif direction == 3:
		change_vector = Vector2(0, 1)
	elif direction == 4:
		change_vector = Vector2(-1, 0)
	elif direction == 5:
		change_vector = Vector2(-1, -1)
	return change_vector


#direction goes from 0-5, clockwise from top
#magnitude is 1 indexed
func get_range(coords, magnitude_range=[1,2], side=null, collision_check=false, direction_range=[0, 6]):
	var return_set = [] #make this a dict?
	var change_vector = Vector2(0, 0)
	for direction in range(direction_range[0], direction_range[1]):
		change_vector = get_change_vector(direction)
		get_range_helper(return_set, change_vector, coords, magnitude_range, side, collision_check)
	return return_set
	
	
func get_direction_from_vector(v):
	var vector = hex_normalize(v)
	if vector == Vector2(0, -1):
		return 0
	elif vector == Vector2(1, 0):
		return 1
	elif vector == Vector2(1, 1):
		return 2
	elif vector == Vector2(0, 1):
		return 3
	elif vector == Vector2(-1, -0):
		return 4
	elif vector == Vector2(-1, -1):
		return 5
	else:
		return null
		
func get_diagonal_direction_from_vector(v):
	var vector = hex_normalize(v)
	if vector == Vector2(1, -1):
		return 0
	elif vector == Vector2(2, 1):
		return 1
	elif vector == Vector2(1, 2):
		return 2
	elif vector == Vector2(-1, 1):
		return 3
	elif vector == Vector2(-2, -1):
		return 4
	elif vector == Vector2(-1, -2):
		return 5
	else:
		return null

#gets the "diagonal" neighbors in the six directions
func get_diagonal_range(coords, magnitude_range=[1, 2], side=null, collision_check=false, direction_range=[0, 6]):
	var return_set = [] #make this a dict?
	var change_vector = Vector2(0, 0)
	for direction in range(direction_range[0], direction_range[1]):
		if direction < 0:
			direction = direction + 6
		if direction == 0:
			change_vector = Vector2(1, -1)
		elif direction == 1:
			change_vector = Vector2(2, 1)
		elif direction == 2:
			change_vector = Vector2(1, 2)
		elif direction == 3:
			change_vector = Vector2(-1, 1)
		elif direction == 4:
			change_vector = Vector2(-2, -1)
		elif direction == 5:
			change_vector = Vector2(-1, -2)

		get_range_helper(return_set, change_vector, coords, magnitude_range, side, collision_check)
	return return_set


func get_range_helper(return_set, change_vector, coords, magnitude_range, side, collision_check):
	for i in range(magnitude_range[0], magnitude_range[1]):
			var new_coords = coords + i * change_vector
			if collision_check:
				if pieces.has(new_coords):
					if side == "ANY":
						return_set.append(new_coords)
					
					elif pieces[new_coords].side == side:
						return_set.append(new_coords)
					break #break regardless on first collision
	
			elif side:
				if pieces.has(new_coords) and pieces[new_coords].side == side:
					return_set.append(new_coords)

			elif locations.has(new_coords) and !pieces.has(new_coords): #only return empty locations
				return_set.append(new_coords)

func cube_to_hex(h): # axial
	return Vector2(h.x, -h.y)
#
#func hex_to_cube(h): # axial
#    var x = h.q
#    var z = h.r
#    var y = -x-z
#    return Vector3(x, y, z)

#range is inclusive
func get_radial_range(coords, radial_range=[1, 1], side=null, collision_check=false):
	var n = radial_range[1]
	var results = []
	for x in range(-n, n + 1):
		for y in range(max(-n, -x - n), min(n, -x + n) + 1): 
			var z = -x - y 
			var hex_coords = coords + cube_to_hex(Vector3(x, y, z))
			if hex_coords != coords and self.locations.has(hex_coords):
				if side==null and !pieces.has(hex_coords):
					results.append(hex_coords)
				
				elif self.pieces.has(hex_coords) and (self.pieces[hex_coords].side == side or side == "ANY"):
					results.append(hex_coords)
	return results
			

#return all pieces on the board of a specified type
func get_all_range(side=null):
	var return_set = []
	for coords in self.pieces:
		if self.pieces[coords].side == side:
			return_set.append(coords)
	return return_set
	
class PathedCoords:
	var steps = 0
	var coords = null
	var previous = null
	func _init(coords, steps, previous):
		self.steps = steps
		self.coords = coords
		self.previous = previous


#get a range if the unit were to take steps and avoid collisions
func get_pathed_range(coords, steps, side=null):
	var return_range = {}
	var explored_range = [PathedCoords.new(coords, 0, null) ]
	while explored_range.size() > 0:
		var current_pathed_coords = explored_range[0]
		explored_range.pop_front()
		if current_pathed_coords.steps < steps:
			var neighbors = get_pathed_range_helper(current_pathed_coords, return_range, side)
			for neighbor_pathed_coords in neighbors:
				if !return_range.has(neighbor_pathed_coords.coords):
					return_range[neighbor_pathed_coords.coords] = neighbor_pathed_coords
					explored_range.append(neighbor_pathed_coords)
			
	return return_range

		
#return all immediate neighbors as PathedCoords
func get_pathed_range_helper(pathed_coords, return_range, side=null):
	var return_list = []
	var neighbor_range = get_range(pathed_coords.coords, [1, 2], side)
	for coords in neighbor_range:
		return_list.append(PathedCoords.new(coords, pathed_coords.steps + 1, pathed_coords))
	return return_list


#helper function to get list of coords from a list of locations and/or pieces
static func get_coord_list(grid_items):
	var return_list = []
	for grid_item in grid_items:
		return_list.append(grid_item.location)
	return return_list
	
static func hex_normalize(vector):
	if(vector.x == 0 or vector.y == 0):
		return vector.normalized()
	else:
		var lowest_denominator = abs(vector.x)
		if(abs(vector.y) < abs(vector.x)):
			lowest_denominator = abs(vector.y)
		return Vector2(vector.x/lowest_denominator, vector.y/lowest_denominator)
		
static func hex_length(vector):
	return round(vector.length()/hex_normalize(vector).length())


#utility function for enemy unit deployment
func get_top_of_column(column):
	return Vector2(column, _LOCATION_Y_OFFSETS[column])


#utility function for player unit deployment
func get_bottom_of_column(column):
	var column_count = 6
	if column % 2 == 1:
		column_count = 7
			
	return Vector2(column, _LOCATION_Y_OFFSETS[column] + column_count - 1)

#get distance in position from a distance in coords
func get_real_distance(coords_distance):
	var length = coords_distance.length()
	var unit_vector = hex_normalize(coords_distance)
	var start_pos = self.locations[Vector2(3, 3)].get_pos()
	var end_pos = self.locations[Vector2(3, 3) + unit_vector].get_pos()
	return length * (end_pos - start_pos)
