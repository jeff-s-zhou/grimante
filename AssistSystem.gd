extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ASSIST_TYPES = {"attack":"attack", "movement":"movement", "defense":"defense"}

var assist_type = null

var assister = null

var assist_disabled = false

signal count_animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	

func initialize(flags):
	if flags.has("no_inspire"):
		self.assist_disabled = true
	self.assist_type = null
	self.assister = null

	
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
		if self.assister != piece:
			self.assister.assist(piece, self.assist_type)
		else:
			self.assister.clear_assist()
		

func clear_assist():
	self.assister = null
	self.assist_type = null


func get_bonus_attack(assisted):
	if self.assist_type == ASSIST_TYPES.attack and self.assister != assisted:
		return 1
	else:
		return 0
	
func get_bonus_movement(assisted):
	if self.assist_type == ASSIST_TYPES.movement and self.assister != assisted:
		return 1
	else:
		return 0
	
func get_bonus_invulnerable(assisted):
	return self.assist_type == ASSIST_TYPES.defense and self.assister != assisted