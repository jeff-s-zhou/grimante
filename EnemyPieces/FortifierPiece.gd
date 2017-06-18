extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var DESCRIPTION = "When this enemy dies, +2 hp to adjacent Enemies."

func initialize(max_hp, modifiers, prototype):
	.initialize("Seraph", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype)

func deathrattle():
	if !self.silenced and self.hp == 0:
		var neighbor_coords_range = get_parent().get_range(self.coords, [1,2], "ENEMY")
		for coords in neighbor_coords_range:
			var neighbor = get_parent().pieces[coords]
			neighbor.heal(2, 1.5) #delay it by 1.5 so it happens when this piece dies
			
func animate_delete_self():
	add_anim_count()
	#get_node("Sprinkles").update() #update particleattractor location after all have moved
	remove_from_group("enemy_pieces")
	get_node("SeraphDeathParticles").set_emit_timeout(0.1)
	get_node("SeraphDeathParticles").set_emitting(true)
	get_node("Tween").interpolate_property(get_node("Physicals"), "visibility/opacity", 1, 0, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("animation_done")
	#get_node("Sprinkles").animate_sprinkles()
	#yield(get_node("Sprinkles"), "animation_done")
	#get_node("/root/Combat/ComboSystem").increase_combo()
	subtract_anim_count()
	get_node("Timer").set_wait_time(1.5)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	self.queue_free()
	