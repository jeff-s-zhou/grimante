extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "When this enemy dies, +2 hp to adjacent Enemies."

func initialize(max_hp, modifiers, prototype):
	.initialize("Seraph", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.assist)

func deathrattle():
	if !self.silenced and !self.frozen and self.hp == 0: #if frozen, the effect would have cancelled out
		add_animation(self, "animate_deathrattle", true)
		var neighbor_coords_range = get_parent().get_range(self.coords, [1,2], "ENEMY")
		for coords in neighbor_coords_range:
			var neighbor = get_parent().pieces[coords]
			neighbor.heal(2) #delay it by 1.5 so it happens when this piece dies
	else:
		.deathrattle()


func animate_deathrattle():
	add_anim_count()
	get_node("SeraphDeathParticles").set_emit_timeout(0.1)
	get_node("SeraphDeathParticles").set_emitting(true)
	get_node("Timer").set_wait_time(0.6)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	subtract_anim_count()
	