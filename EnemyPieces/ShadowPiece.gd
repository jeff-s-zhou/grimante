extends "EnemyPiece.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var max_hp = 5
var mirrored_hero_name = null
var DESCRIPTION = "Only the mirrored Hero can kill this piece."

#todo: initialize with the mirrored hero name
func initialize(max_hp, modifiers, prototype):
	if modifiers.has("unit_name"): #modifiers is only a dict when made through the level editor
		self.mirrored_hero_name = unit_name 
	.initialize("Nemesis", DESCRIPTION, Vector2(0, 1), max_hp, modifiers, prototype, TYPES.selfish)


func get_actual_damage(damage, unit):
	if self.hp > 0:
		.get_actual_damage(damage, unit)
	else:
		if !unit.unit_name == self.mirrored_hero_name:
			.get_actual_damage(damage, unit)
		else:
			.get_actual_damage(0, unit)
	
