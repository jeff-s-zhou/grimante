extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	
func set_free_deploy():
	get_node("Label").set_text("Press SPACE to start.")
	
func player_turn_start():
	get_node("Label").set_text("Press SPACE to end turn.")
	
func player_turn_end():
	get_node("Label").set_text("")
	
func clear():
	get_node("Label").set_text("")