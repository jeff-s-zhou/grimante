extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


signal deployed
signal end_turn

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

func _input(event):
	if event.is_action("ui_accept") and event.is_pressed():
		if get_parent().state == get_parent().STATES.game_start:
			get_node("Label").set_text("")
			emit_signal("deployed")
		if get_parent().state == get_parent().STATES.player_turn:
			emit_signal("end_turn")