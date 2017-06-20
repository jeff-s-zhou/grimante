extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var modifier

onready var enemy_modifiers = get_node("/root/constants").enemy_modifiers

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(modifier):
	self.modifier = modifier
	if modifier == enemy_modifiers["Poisonous"]:
		self.set_poisonous(true)
	elif modifier == enemy_modifiers["Shield"]:
		self.set_shield(true)
	elif modifier == enemy_modifiers["Cloaked"]:
		self.set_cloaked(true)
	elif modifier == enemy_modifiers["Predator"]:
		self.set_rabid(true)
	elif modifier == enemy_modifiers["Corrosive"]:
		self.set_corrosive(true)


func set_cloaked(flag):
	if flag:
		get_node("EnemyOverlays/Cloaked").show()
	else:
		get_node("EnemyOverlays/Cloaked").hide()
	
func set_shield(flag):
	if flag:
		get_node("EnemyEffects/Bubble").show()
	else:
		get_node("EnemyEffects/Bubble").hide()


func set_poisonous(flag):
	get_node("EnemyEffects/DeathTouch").set_emitting(flag)
		

func set_rabid(flag):
	get_node("EnemyEffects/RabidParticles").set_emitting(flag)
	
	
func set_corrosive(flag):
	get_node("EnemyEffects/CorrosiveParticles").set_emitting(flag)

func input_event(event):
	get_parent().toggle_modifier(self.modifier)
