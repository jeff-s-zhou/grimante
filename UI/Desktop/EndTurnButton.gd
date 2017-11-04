extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal pressed
signal deploy_pressed

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("EndTurnButton").connect("pressed", self, "handle_pressed")
	get_node("DeployButton").connect("pressed", self, "handle_deploy_pressed")

func set_disabled(flag):
	get_node("EndTurnButton").set_disabled(flag)
	
func set_deploying(flag):
	if flag:
		get_node("EndTurnButton").hide()
		get_node("DeployButton").show()
	else:
		get_node("DeployButton").hide()
		get_node("EndTurnButton").show()
	
func handle_pressed():
	emit_signal("pressed")
	
func handle_deploy_pressed():
	emit_signal("deploy_pressed")