
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var coords

var raining = false

var deployable = false

var shadow_wall = false

signal is_targeted(location)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite").set_self_opacity(0.4)
	connect("mouse_enter", self, "_mouse_entered")
	connect("mouse_exit", self, "_mouse_exited")
	set_process_input(true)
	
func debug():
	get_node("Label").set_text(str(coords.x) + "," + str(coords.y))
	
func set_coords(coords):
	self.coords = coords
	
func set_reinforcement_indicator(flag):
	if flag:
		get_node("ReinforcementIndicator").show()
	else:
		get_node("ReinforcementIndicator").hide()
		
		
func set_deployable_indicator(flag):
	if flag:
		get_node("DeployableIndicator").show()
	else:
		get_node("DeployableIndicator").hide()
	
func set_rain(flag):
	self.raining = flag
	if flag:
		get_node("/root/AnimationQueue").enqueue(get_node("StormEffect"), "animate_set_rain", false)
	else:
		get_node("StormEffect/RainParticles").hide()
		
func set_shadow_wall(flag):
	self.shadow_wall = flag
	if flag:
		get_node("WallFront").show()
		get_node("WallBack").show()
	else:
		get_node("WallFront").hide()
		get_node("WallBack").hide()
		
		
func activate_lightning():
	self.raining = false
	get_node("/root/AnimationQueue").enqueue(get_node("StormEffect"), "animate_lightning", true)


#when another unit is able to move to this location, it calls this function
func movement_highlight():
	get_node("Sprite").play("movement_hover")
	
func attack_highlight():
	get_node("Sprite").play("attack_hover")
	
func reset_highlight():
	get_node("Sprite").play("default")
	external_set_opacity(0.4)
	
func _mouse_entered():
	get_node("SamplePlayer").play("tile_hover")
	get_node("Sprite").set_self_opacity(1.0)
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	if get_parent().selected != null:
		get_parent().selected.predict(self.coords)

func _mouse_exited():
	#get_parent().current_location = null
	#emit_signal("location_is", null)
	get_node("Sprite").set_self_opacity(0.4)
	if get_parent().selected != null:
		get_parent().reset_prediction()

func input_event(event):
	if event.is_action("select") and event.is_pressed():
		get_parent().set_target(self)

func external_set_opacity(value=1.0):
	get_node("Sprite").set_self_opacity(value)
	
func get_size():
	return get_node("Sprite").get_item_rect().size
	
