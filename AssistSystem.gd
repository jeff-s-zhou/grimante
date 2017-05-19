extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const ASSIST_TYPES = {"attack":1, "movement":2, "invulnerable":3, "finisher":4}

var assist_type = null

var assister = null

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
	get_node("/root/AnimationQueue").enqueue(self, "animate_activate_assist", false, [self.assist_type])
	
	
func activate_assist(assist_type, assister):
	self.assister = assister
	self.assist_type = assist_type
	get_node("/root/AnimationQueue").enqueue(self, "animate_activate_assist", false, [self.assist_type])
	self.assister.activate_assist(self.assist_type)


func animate_activate_assist(assist_type):
	if assist_type == ASSIST_TYPES.attack:
		get_node("Label").set_text("Inspire: +1 Attack")
	elif assist_type == ASSIST_TYPES.movement:
		get_node("Label").set_text("Inspire: +1 Range")
	elif assist_type == ASSIST_TYPES.invulnerable:
		get_node("Label").set_text("Inspire: Protect")
	elif assist_type == null:
		get_node("Label").set_text("")
		

func assist(piece):
	if self.assister != null:
		self.assister.assist(piece, self.assist_type)
		

func clear_assist():
	self.assister = null
	self.assist_type = null
	get_node("/root/AnimationQueue").enqueue(self, "animate_activate_assist", false, [self.assist_type])


func get_bonus_attack():
	if self.assist_type == ASSIST_TYPES.attack or self.assist_type == ASSIST_TYPES.finisher:
		return 1
	else:
		return 0
	
func get_bonus_movement():
	if self.assist_type == ASSIST_TYPES.movement or self.assist_type == ASSIST_TYPES.finisher:
		return 1
	else:
		return 0
	
func get_bonus_invulnerable():
	return self.assist_type == ASSIST_TYPES.invulnerable or self.assist_type == ASSIST_TYPES.finisher