extends "res://Tutorials/tutorial.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func get():
	var tutorial = TutorialPrototype.instance()
	
	var fa_text1 = "The Pyromancer is going to set the world in flames, and no one can stop him!"
	var fa_text2 = "Move the Pyromancer up and use its Indirect Attack."
	var text = ["Whenever the Pyromancer moves, it tosses a Firebomb in the direction it moves.", 
	"Enemies hit take {2} damage, and are inflicted with {Burn}."]
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(2, 6), fa_text2, text)
	
	text = ["Burned Enemies take {1 damage per turn}."]
	add_enemy_end_rule(tutorial, 1, text)
	
	fa_text1 = "The Pyromancer can only move forward because he's insane." 
	fa_text2 = "Being insane, the Pyromancer can only attack by moving."
	text = ["Fire will spread to a single adjacent enemy at random.",
	 "The fire will continue to spread to a single adjacent enemy {up to 4 times}."]
	add_forced_action(tutorial, 2, Vector2(2, 6), fa_text1, Vector2(2, 5), fa_text2, text)
	return tutorial
	