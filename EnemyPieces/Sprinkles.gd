extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done
var particle_endpoint

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func set_particle_endpoint(global_pos):
	self.particle_endpoint = global_pos
	get_node("ParticleAttractor2D").set_global_pos(global_pos)

#need to update the position of the attractor because it'll move relative to the piece
func update():
	get_node("ParticleAttractor2D").set_global_pos(self.particle_endpoint)

func animate_sprinkles():
	get_node("Particles2D").set_emitting(true)
	get_node("Timer").set_wait_time(0.3)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	get_node("Particles2D").set_emitting(false)
	get_node("Timer").set_wait_time(1.5)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")