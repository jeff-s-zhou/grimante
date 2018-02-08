extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func get_trial1_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["From here on out, in order to unlock new Heroes, you must beat their Trials.",
	"Each Trial must be beaten in the turn limit.",
	"The first set of Trials is to unlock the Archer.",
	"The Archer's Direct Attack is to shoot an arrow from a distance for {3} damage."]
	
	add_hint(tutorial, 1, hint, Vector2(3, 7))
	hint = ["If the Archer's Arrow {kills}, it continues travelling and deals {1 less damage to successive enemies.}"]
	
	add_hint(tutorial, 2, hint)
	
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["When the Archer moves, its Indirect Attack allows it to automatically fire a Piercing Arrow upwards."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["The Archer can also shoot in \"hex diagonal\" directions to hit tricky shots."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
	
func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	
	var hint = ["All projectiles are {blocked} by other Heroes."]
	
	add_hint(tutorial, 1, hint)
	
	return tutorial
