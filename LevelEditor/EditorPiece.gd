extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var prototype
var hp
var modifiers = {}
var name = null
onready var enemy_modifiers = get_node("/root/constants").enemy_modifiers
onready var roster = get_node("/root/constants").enemy_roster

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
	var enemy_names = roster.keys()
	for enemy_name in enemy_names:
		if prototype_name == enemy_name:
			self.name = enemy_name
			get_node("AnimatedSprite").set_animation(enemy_name)
	
	self.state = STATES.bar
	set_z(3)
	
		
func initialize(name, turn, coords, hp, modifiers=null):
	self.name = name
	get_node("AnimatedSprite").set_animation(name)
	self.turn = turn
	set_health(hp)
	set_modifiers(modifiers)
	self.coords = coords
	var pos = get_node("/root/LevelEditor").get_current_editor_grid().locations[coords].get_pos()
	set_pos(pos)
	self.state = STATES.instanced
	
func edit(hp, modifiers=null):
	set_health(hp)
	set_modifiers(modifiers)
	
func delete():
	get_node("/root/LevelEditor").get_current_editor_grid().pieces.erase(coords)
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
	get_node("/root/LevelEditor").get_current_editor_grid().pieces[self.coords] = null
	self.coords = coords
	get_node("/root/LevelEditor").get_current_editor_grid().pieces[self.coords] = self
	var pos = get_node("/root/LevelEditor").get_current_editor_grid().locations[coords].get_pos()
	set_pos(pos)

func set_health(hp):
	self.hp = hp
	get_node("HealthDisplay").set_health(hp)

func set_modifiers(modifiers):
	for modifier in modifiers:
		print(modifier)
		if modifier == enemy_modifiers["Poisonous"]:
			self.set_poisonous(true)
		elif modifier == enemy_modifiers["Shield"]:
			self.set_shield(true)
		elif modifier == enemy_modifiers["Cloaked"]:
			self.set_cloaked(true)
			
func set_cloaked(flag):
	if flag:
		var cloaked = enemy_modifiers["Cloaked"]
		self.modifiers["Cloaked"] = cloaked
		get_node("EnemyOverlays/Cloaked").show()
	else:
		self.modifiers.erase("Cloaked")
		get_node("EnemyOverlays/Cloaked").hide()
	
func set_shield(flag):
	if flag:
		var shield = enemy_modifiers["Shield"]
		self.modifiers["Shield"] = shield
		get_node("EnemyEffects/Bubble").show()
	else:
		self.modifiers.erase("Shield")
		get_node("EnemyEffects/Bubble").hide()
	
func set_poisonous(flag):
	if flag:
		var deadly = enemy_modifiers["Poisonous"]
		get_node("EnemyEffects/DeathTouch").set_emitting(true)
		self.modifiers["Poisonous"] = deadly
	else:
		self.modifiers.erase("Poisonous")
		get_node("EnemyEffects/DeathTouch").set_emitting(false)
		

func save():
	var save_dict = {
		name = self.name,
		pos_x = coords.x, #Vector2 is not supported by json
		pos_y = coords.y,
		hp = self.hp,
		turn = self.turn,
		modifiers = self.modifiers
	}
	return save_dict