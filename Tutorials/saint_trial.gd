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
	var text = ["The Saint is here to serve.", 
	"The Saint's Indirect Attack is Silence.",
	"Whenever the Saint moves to a tile, it {disables the special abilities} of all adjacent enemies.",]
	add_player_start_rule(tutorial, 1, text, Vector2(4, 7))
	return tutorial
	
func get_trial2_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Saint has a unique movement range.",
	"The Saint by default has {0 movement range} (1 when Inspired with Movement).",
	"Instead, the Saint can move {adjacent to any other Hero}."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial
	
func get_trial3_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["The Saint's Passive is Threads of Infinite Light.",
	"Whenever a hex line or hex-diagonal line is formed between the Saint and another Hero, deal {1} damage to all enemies in between."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial
	
func get_trial4_hints():
	var tutorial = TutorialPrototype.instance()
	var text = ["Hint: The Saint's passive can also trigger when other Heroes move."]
	add_player_start_rule(tutorial, 1, text)
	return tutorial