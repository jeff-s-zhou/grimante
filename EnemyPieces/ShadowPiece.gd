extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var mirrored_hero_name = null
var DESCRIPTION = "Only the mirrored Hero can kill this piece."

#todo: initialize with the mirrored hero name
func initialize(max_hp, modifiers, prototype):
	print("modifiers : ", modifiers)
	if modifiers.has("mirrored_hero"): #modifiers is only a dict when made through the level editor
		self.mirrored_hero_name = modifiers["mirrored_hero"]
		get_node("Physicals/AnimatedSprite").set_animation(self.mirrored_hero_name.to_lower())
	else:
		self.mirrored_hero_name = "Cavalier"
	.initialize("Nemesis", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.nemesis)


func get_actual_damage(damage, unit):
	if unit != null:
		var name
		if typeof(unit) == TYPE_STRING: #patched on for frost knight's explosion
			name = unit.to_lower()
		else:
			name = unit.unit_name.to_lower()
		
		if self.silenced or name.to_lower() == self.mirrored_hero_name.to_lower():
			return .get_actual_damage(damage, unit)
		else:
			var max_damage = min(damage, self.hp - 1)
			return .get_actual_damage(max_damage, unit)
	return .get_actual_damage(damage, unit)
		
