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
	
	var fa_text1 = "The Archer is here!"
	var fa_text2 = "The Archer can Direct Attack from a distance by firing a Piercing Arrow."
	var text = ["The Piercing Arrow hits the closest target in any hexagonal direction for {3} damage."]
	
	add_forced_action(tutorial, 1, Vector2(3, 7), fa_text1, Vector2(3, 4), fa_text2, text)
	
	fa_text1 = "The Archer's Piercing Arrow has a special effect when it kills an enemy."
	text = ["If the Archer's Piercing Arrow kills, it continues to travel.", 
	"The arrow deals {1 less damage to each successive enemy} until it fails to kill, or its damage reaches {0}."]
	
	add_forced_action(tutorial, 2, Vector2(3, 7), fa_text1, Vector2(3, 5), fa_text1, text)
	
	fa_text1 = "The Archer can also shoot in \"hex diagonal\" directions to hit tricky shots."
	add_forced_action(tutorial, 3, Vector2(3, 7), fa_text1, Vector2(1, 3), fa_text1)
	
	fa_text1 = "The Archer doesn't just have to sit still."
	text = ["When the Archer moves, her Indirect Attack causes her to automatically fire a Piercing Arrow upwards."]
	add_forced_action(tutorial, 4, Vector2(3, 7), fa_text1, Vector2(4, 7), fa_text1, text)
	
	text = ["The Archer's shots are {blocked} by other Heroes.", 
	"Clear the board this turn."]
	add_player_start_rule(tutorial, 5, text)
	
	return tutorial
