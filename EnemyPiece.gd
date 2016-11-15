
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var coords #enemies move automatically each turn a certain number of spaces forward
var hp
var type
var side = "ENEMY"

signal broke_defenses

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func initialize(type):
	add_to_group("enemy_pieces")
	self.type = type
	set_hp(type.max_hp)
	
func set_hp(hp):
	if hp <= 0:
		delete_self()
	self.hp = hp
	get_node("Label").set_text(str(self.hp))
	
func delete_self():
	get_parent().pieces.erase(self.coords)
	remove_from_group("enemy_pieces")
	self.queue_free()
	
	
func attacked(damage):
	set_hp(self.hp - damage)
	
	
func set_coords(coords):
	self.coords = coords

#when another unit is able to move to this location, it calls this function
func movement_highlight():
	pass
	
func movement_unhighlight():
	pass
	
func move(old_coords, new_coords):
	self.coords = new_coords
	get_parent().move_piece(old_coords, new_coords)
	var location = get_parent().locations[new_coords]
	move_animation(location.get_pos())
	
func move_animation(new_position):
	var increment = (new_position - get_pos()).normalized()
	while(!(new_position - get_pos()).length() < 1.0):
		print(get_pos() + increment)
		set_pos(get_pos() + increment)
	set_pos(new_position)
	


#called at the start of enemy turn
func turn_update():
	if !get_parent().locations.has(coords + type.movement_value):
		emit_signal("broke_defenses")
		delete_self()
	else:
		if get_parent().pieces.has(coords + type.movement_value):
			#if a player piece, move it first
			var obstructing_piece = get_parent().pieces[coords + type.movement_value]
			if obstructing_piece.side == "PLAYER":
				obstructing_piece.push(type.movement_value)
				
		#now if the space in front is free, move it
		if !get_parent().pieces.has(coords + type.movement_value):
			move(coords, coords + type.movement_value)
		