extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "When this enemy dies, +2 hp to adjacent Enemies."

func initialize(max_hp, modifiers, prototype):
	.initialize("Seraph", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, self.GREEN_EXPLOSION_SCENE)

func deathrattle():
	if !self.silenced and self.hp == 0:
		var neighbor_coords_range = get_parent().get_range(self.coords, [1,2], "ENEMY")
		for coords in neighbor_coords_range:
			var neighbor = get_parent().pieces[coords]
			neighbor.heal(2, 1.5) #delay it by 1.5 so it happens when this piece dies

	
func animate_delete_self():
	add_anim_count()
	get_node("SeraphDeathParticles").set_emit_timeout(0.1)
	get_node("SeraphDeathParticles").set_emitting(true)
	get_node("SamplePlayer").play("rocket glass explosion 5")
	get_node("Physicals").set_opacity(0)
	emit_signal("shake")
	var explosion = self.explosion_prototype.instance()
	add_child(explosion)
	explosion.set_emit_timeout(0.3)
	explosion.set_emitting(true)
	get_node("Timer").set_wait_time(0.5)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	subtract_anim_count()
	#let it resolve any other animations
	print("enemy deleting self")
	print(self.debug_anim_counter)
	get_node("Timer").set_wait_time(3)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	print(self.debug_anim_counter)
	self.queue_free()

	