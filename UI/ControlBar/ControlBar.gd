extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(flags, combat_scene):
	get_node("DeployButton").connect("pressed", combat_scene, "handle_deploy")
	get_node("EndTurnButton").connect("released", combat_scene, "handle_end_turn_released")
	get_node("EndTurnButton").connect("holding", combat_scene, "holding_end_turn")
	get_node("EndTurnButton").set_disabled(true)
	
	if flags.has("no_stars"):
		get_node("StarBar").disable()
		
	if flags.has("bonus_star"):
		get_node("StarBar").add_star()
		
	if flags.has("sandbox"):
		get_node("BackButton").show()
		get_node("ForwardButton").show()
		get_node("BackButton").connect("pressed", combat_scene, "previous_level")
		get_node("ForwardButton").connect("pressed", combat_scene, "next_level")