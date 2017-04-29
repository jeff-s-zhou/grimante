
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var coords

var raining = false

var deployable = false

var shadow_wall = false

var shifting_direction = null

var corpse = null

signal animation_done
signal count_animation_done

signal is_targeted(location)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite").set_self_opacity(0.4)
	connect("mouse_enter", self, "_mouse_entered")
	connect("mouse_exit", self, "_mouse_exited")
	
func debug():
	get_node("Label").set_text(str(coords.x) + "," + str(coords.y))
	
func set_coords(coords):
	self.coords = coords
	
func add_corpse(player_piece):
	self.corpse = player_piece

func resurrect():
	if !get_parent().pieces.has(coords):
		self.corpse.resurrect()
		self.corpse = null
		
	
func animate_add_corpse():
	get_node("CorpseIndicator").set_animation(self.corpse.unit_name.to_lower())
	get_node("CorpseIndicator").show()
	
func animate_hide_corpse():
	get_node("CorpseIndicator").hide()
	
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
		get_node("/root/AnimationQueue").enqueue(get_node("StormEffect"), "animate_hide_rain", false)
	
		
func set_shadow_wall(flag):
	self.shadow_wall = flag
	if flag:
		get_node("WallFront").show()
		get_node("WallBack").show()
	else:
		get_node("WallFront").hide()
		get_node("WallBack").hide()


func set_shifting_sands(direction):
	self.shifting_direction = direction
	get_node("ShiftingSands").show()
		
		
func animate_lightning():
	get_node("StormEffect").animate_lightning()
	set_rain(false)
	yield(get_node("StormEffect"), "animation_done")
	emit_signal("animation_done")


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
	if get_node("InputHandler").is_select(event):
		get_parent().set_target(self)

func external_set_opacity(value=1.0):
	get_node("Sprite").set_self_opacity(value)
	
func get_size():
	return get_node("Sprite").get_item_rect().size