extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ASSIST_TYPES = {"attack":1, "movement":2, "invulnerable":3}

var assist_type = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func activate_assist(assist_type):
	self.assist_type = assist_type


func clear_assist():
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
	return self.assist_type == ASSIST_TYPES.invulnerable