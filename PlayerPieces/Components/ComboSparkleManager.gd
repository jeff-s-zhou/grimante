extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done

const ASSIST_TYPES = {"attack":1, "movement":2, "invulnerable":3, "finisher":4}


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func animate_activate_assist(assist_type):
	if assist_type == ASSIST_TYPES.attack:
		get_node("ComboSparklesRed").set_emitting(true)
	elif assist_type == ASSIST_TYPES.movement:
		get_node("ComboSparklesYellow").set_emitting(true)
	elif assist_type == ASSIST_TYPES.invulnerable:
		get_node("comboSparklesBlue").set_emitting(true)
	elif assist_type == ASSIST_TYPES.finisher:
		pass
	
	
func animate_assist(assist_type, pos_difference):
	
	var sparkles = null
	if assist_type == ASSIST_TYPES.attack:
		sparkles = get_node("ComboSparklesRed")
	elif assist_type == ASSIST_TYPES.movement:
		sparkles = get_node("ComboSparklesYellow")
	elif assist_type == ASSIST_TYPES.invulnerable:
		sparkles = get_node("ComboSparklesBlue")
	elif assist_type == ASSIST_TYPES.finisher:
		sparkles = get_node("ComboSparklesBlue")

	sparkles.get_node("ParticleAttractor2D").set_pos(pos_difference)
	sparkles.get_node("ParticleAttractor2D").set_enabled(true)
#	get_node("Timer").set_wait_time(0.1)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	sparkles.set_emitting(false)
	get_node("Timer").set_wait_time(0.4)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	sparkles.get_node("ParticleAttractor2D").set_enabled(false)
	emit_signal("animation_done")
	
func animate_clear_assist(assist_type):
	var sparkles = null
	if assist_type == ASSIST_TYPES.attack:
		sparkles = get_node("ComboSparklesRed")
	elif assist_type == ASSIST_TYPES.movement:
		sparkles = get_node("ComboSparklesYellow")
	elif assist_type == ASSIST_TYPES.invulnerable:
		sparkles = get_node("ComboSparklesBlue")
	elif assist_type == ASSIST_TYPES.finisher:
		sparkles = get_node("ComboSparklesBlue")
	sparkles.set_emitting(false)
