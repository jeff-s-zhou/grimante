extends "LevelSet.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func get_set():
	return Set.new(9, "Ninth",
	[final_level()], [])

	
func final_level():
	var pieces
	var score_guide
	pieces = load_level("clear_test.level")
	score_guide = {1:5, 2:3, 3:3, 4:4} #not tested
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(00046, "Saint Drive", allies, enemies, 4, null, extras)

