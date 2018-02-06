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
	[final_level(), final_level2()], [])

	
func final_level():
	var pieces
	var score_guide
	pieces = load_level("final_level.level")
	score_guide = {1:6, 2:6, 3:5, 4:4, 5:3, 6:2} 
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(52, "Penultimayhem", allies, enemies, 6, null, extras)
	
	
func final_level2():
	var pieces
	var score_guide
	pieces = load_level("final_level2.level")
	score_guide = {1:6, 2:5, 3:4, 4:3, 5:2}
	var raw_enemies = pieces[0]
	var allies = pieces[1]
	var enemies = EnemyWrappers.FiniteCuratedWrapper.new(raw_enemies)
	var extras = {"free_deploy":false, "flags":[], "score_guide":score_guide}
	return LevelTypes.Timed.new(53, "Mayhem", allies, enemies, 6, null, extras)


