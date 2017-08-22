
extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var DESCRIPTION = "Before moving, shoots a Fireball downwards if not blocked by other Enemies. The Fireball functions the same as a regular Enemy Attack."

const fireball_prototype = preload("res://EnemyPieces/Components/DragonFireball.tscn")

func initialize(max_hp, modifiers, prototype):
	.initialize("Fire Drake", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.attack)

func turn_start():
	if !self.silenced:
		var fireball_range = get_parent().get_range(self.coords, [1, 9], "PLAYER", true, [3, 4])
		if fireball_range != []:
			fireball(fireball_range[0])

func fireball(coords):
	add_animation(self, "animate_fireball", true, [coords])
	get_parent().pieces[coords].attacked(self)

func animate_fireball(coords):
	add_anim_count()
	var fireball = fireball_prototype.instance()
	add_child(fireball)
	
	get_node("Tween").interpolate_property(fireball, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	
	var target_pos = (get_parent().locations[coords].get_pos() - get_pos())

	get_node("Tween").interpolate_property(fireball, "transform/pos", fireball.get_pos(), target_pos, 0.7, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	
	remove_child(fireball)
	emit_signal("animation_done")
	subtract_anim_count()
