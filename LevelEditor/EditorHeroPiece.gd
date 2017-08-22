extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var prototype
var name = null
onready var roster = get_node("/root/constants").hero_roster

var is_hero = true

var coords

var turn

var STATES = {"bar":0, "instanced":1}

var state = null

var is_selected = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize_on_bar(prototype_name):
	var hero_names = roster.keys()
	for hero_name in hero_names:
		if prototype_name == hero_name:
			self.name = hero_name
			get_node("AnimatedSprite").set_animation(hero_name)
	
	self.state = STATES.bar
	set_z(3)
	
func is_targetable():
	return true
	
func set_targetable(flag):
	get_node("CollisionArea").set_monitorable(flag)

	
		
func initialize(name, turn, coords):
	self.name = name
	get_node("AnimatedSprite").set_animation(name)
	self.turn = turn
	self.coords = coords
	var pos = get_node("/root/LevelEditor").get_current_editor_grid().locations[self.coords].get_pos()
	set_pos(pos)
	self.state = STATES.instanced
	
func edit(hp, modifiers=null):
	set_health(hp)
	set_modifiers(modifiers)
	
func delete():
	get_node("/root/LevelEditor").get_current_editor_grid().remove_piece(self.coords)
	queue_free()
	
func input_event(event):
	if get_node("/root/LevelEditor").selected == null:
		get_node("/root/LevelEditor").selected = self

	#if we're already selected, and tapped again
	elif get_node("/root/LevelEditor").selected == self and self.is_instanced():
		get_node("/root/LevelEditor").modify_unit()
		
func is_instanced():
	return self.state == STATES.instanced
	
	
#called when the piece is already instanced and we're moving it on the grid
func move(coords):
	get_node("/root/LevelEditor").get_current_editor_grid().move_piece(self.coords, coords)
	self.coords = coords
	var pos = get_node("/root/LevelEditor").get_current_editor_grid().locations[coords].get_pos()
	set_pos(pos)
		

func save():
	var save_dict = {
		name = self.name,
		pos_x = coords.x, #Vector2 is not supported by json
		pos_y = coords.y,
		turn = self.turn,
	}
	return save_dict