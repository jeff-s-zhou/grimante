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
	get_node("Sprite").set_opacity(0.4)
	connect("mouse_enter", self, "_mouse_entered")
	connect("mouse_exit", self, "_mouse_exited")
	
func debug():
	get_node("Label").set_text(str(coords.x) + "," + str(coords.y))
	
func set_coords(coords):
	self.coords = coords
	
func set_targetable(flag):
	if flag:
		set_opacity(1)
		set_pickable(true)
	else:
		set_opacity(0.5)
		set_pickable(false)
	
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


func set_shifting_sands(direction, mask_index):
	#not sure if we can exceed 12 bits for the mask
	if mask_index < 12:
		self.shifting_direction = direction
		get_node("ShiftingSands").set_shifting_direction(direction)
		get_node("ShiftingSands").set_mask_index(mask_index)
		get_node("ShiftingSands").show()
		get_node("Sprite").hide()
	
func rotate_shifting():
	if self.shifting_direction != null:
		self.shifting_direction = (self.shifting_direction + 1) % 6
		get_node("/root/AnimationQueue").enqueue(get_node("ShiftingSands"), "animate_rotate", true)
		
		
func animate_lightning():
	get_node("StormEffect").animate_lightning()
	yield(get_node("StormEffect"), "animation_done")
	emit_signal("animation_done")


#when another unit is able to move to this location, it calls this function
func movement_highlight():
	get_node("HighlightSprite").show()
	
func attack_highlight():
	get_node("HighlightSprite").show()
	
func indirect_highlight():
	get_node("HighlightSprite").play("indirect")
	
func reset_highlight():
	get_node("HighlightSprite").hide()
	get_node("HighlightSprite").play("default")
	if shifting_direction != null:
		get_node("ShiftingSands").reset_highlight()
	else:
		get_node("Sprite").set_opacity(0.4)
	
func _mouse_entered():
	get_node("SamplePlayer").play("tile_hover")
	if shifting_direction != null:
		get_node("ShiftingSands").highlight()
	else:
		get_node("Sprite").set_opacity(1.0)
	get_node("Timer").set_wait_time(0.01)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	get_parent().predict(self.coords)

func _mouse_exited():
	if shifting_direction != null:
		get_node("ShiftingSands").reset_highlight()
	else:
		get_node("Sprite").set_opacity(0.4)
	get_parent().reset_prediction()


func input_event(event):
	get_parent().set_target(self)

func external_set_opacity(value=1.0):
	get_node("Sprite").set_opacity(value)
	
func get_size():
	return get_node("Sprite").get_item_rect().size