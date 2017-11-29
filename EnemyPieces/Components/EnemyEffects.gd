extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var descriptions = {
"Poisonous": "Any Hero attacked by this Enemy is KOed.",
"Shield": "The first attack on this Enemy is nullified, as well as any applied status effects.",
"Cloaked": "This Enemy's health and identity is unknown until is it attacked, or a Hero moves adjacent to it.",
"Unstable": "This Enemy loses 1 health at the end of each turn. When it dies, it damages all adjacent Heroes."
}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate_shield_explode():
	get_node("Bubble").hide()
	get_node("EnemyShieldExplosionParticles").set_emit_timeout(0.3)
	get_node("EnemyShieldExplosionParticles").set_emitting(true)