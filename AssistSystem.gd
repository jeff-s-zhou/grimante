extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ASSIST_TYPES = {"attack":"attack", "movement":"movement", "defense":"defense"}

var assist_type = null

var assister = null

var assist_disabled = true

signal count_animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func reset_combo():
	self.assist_type = null
	if self.assister != null:
		self.assister.clear_assist()
		self.assister = null
	
	
func activate_assist(assist_type, assister):
	if !self.assist_disabled:
		self.assister = assister
		self.assist_type = assist_type
		self.assister.activate_assist(self.assist_type)

		

func assist(piece):
	if self.assister != null:
		self.assister.assist(piece, self.assist_type)
		

func clear_assist():
	self.assister = null
	self.assist_type = null


func get_bonus_attack():
	if self.assist_type == ASSIST_TYPES.attack:
		return 1
	else:
		return 0
	
func get_bonus_movement():
	if self.assist_type == ASSIST_TYPES.movement:
		return 1
	else:
		return 0
	
func get_bonus_invulnerable():
	return self.assist_type == ASSIST_TYPES.defense