extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("FinalHeroScreen").connect("final_hero_selected", self, "final_hero_selected")
	get_node("Runes").set_green(1)
	#get_node("Runes1").set_green(0)
	
func initialize(flags, combat_scene):
	get_node("Combat/DeployButton").connect("pressed", combat_scene, "handle_deploy")
	get_node("Combat/EndTurnButton").connect("released", combat_scene, "handle_end_turn_released")
	get_node("Combat/EndTurnButton").connect("holding", combat_scene, "holding_end_turn")
	get_node("Combat/EndTurnButton").set_disabled(true)
	
	if flags.has("no_stars"):
		get_node("Combat/StarBar").disable()
		
	if flags.has("bonus_star"):
		get_node("Combat/StarBar").add_star()
		
	if flags.has("sandbox"):
		get_node("Combat/BackButton").show()
		get_node("Combat/ForwardButton").show()
		get_node("Combat/BackButton").connect("pressed", combat_scene, "previous_level")
		get_node("Combat/ForwardButton").connect("pressed", combat_scene, "next_level")


func set_deploying(flag):
	if flag:
		get_node("Combat/DeployButton").show()
		get_node("FinalHeroScreen").show()
		get_node("Combat").hide()
	else:
		get_node("FinalHeroScreen").queue_free()
		get_node("Combat/DeployButton").hide()
		get_node("Combat/EndTurnButton").show()
		
		
func final_hero_selected():
	get_node("Combat").show()

func add_piece_on_bar(piece):
	#add_child(piece)
	get_node("FinalHeroScreen").initialize(piece)


		
func set_disabled(flag):
	get_node("Combat/StarBar").set_disabled(flag)
	get_node("Combat/EndTurnButton").set_disabled(flag)