extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var coords

#STATE
var raining = false
var deployable = false
var corpse = null

var default_opacity = 0.2

var highlight_opacity = 0.7

var deploying_flag = false

var indirect_highlighting = true

signal animation_done
signal count_animation_done

signal is_targeted(location)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite").set_opacity(self.default_opacity)
	connect("mouse_enter", self, "_mouse_entered")
	connect("mouse_exit", self, "_mouse_exited")
	
func soft_reset():
	set_rain(false)
	self.corpse = null
	set_deployable_indicator(false)
	animate_hide_corpse()
	
func debug():
	get_node("Label").set_text(str(coords.x) + "," + str(coords.y))
	
func hide_indirect_highlighting():
	self.indirect_highlighting = false
	
func set_coords(coords):
	self.coords = coords
	
func set_endzone():
	get_node("EndzoneHighlight").show()
	
func set_targetable(flag):
	if flag:
		set_opacity(self.highlight_opacity)
		set_pickable(true)
	else:
		set_opacity(self.default_opacity)
		set_pickable(false)

func is_targetable():
	return self.is_pickable()

func add_corpse(player_piece):
	self.corpse = player_piece
	
func animate_add_corpse():
	get_node("CorpseIndicator").set_animation(self.corpse.unit_name.to_lower())
	get_node("CorpseIndicator").show()
	
func animate_hide_corpse():
	get_node("CorpseIndicator").hide()
	
func set_reinforcement_indicator(type=null):
	if type != null:
		get_node("ReinforcementIndicator").display(type)
		get_node("ReinforcementIndicator").show()
	else:
		get_node("ReinforcementIndicator").hide()
		
		
func set_deployable_indicator(flag):
	if flag:
		get_node("DeployIndicator").display("friendly")
		get_node("DeployIndicator").show()
	else:
		get_node("DeployIndicator").hide()
	
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
	pass
	
func rotate_shifting():
	pass
		
func animate_lightning():
	get_node("StormEffect").animate_lightning()
	yield(get_node("StormEffect"), "animation_done")
	emit_signal("animation_done")


#when another unit is able to move to this location, it calls this function
func movement_highlight():
	if !self.deploying_flag:
		get_node("HighlightSprite").show()
		
func start_deploy_phase():
	self.deploying_flag = true
	
func deploy():
	self.deploying_flag = false
	
func attack_highlight():
	get_node("HighlightSprite").show()
	
func indirect_highlight():
	if self.indirect_highlighting:
		get_node("HighlightSprite").play("indirect")
	
func reset_highlight():
	get_node("HighlightSprite").hide()
	get_node("HighlightSprite").play("default")
	get_node("Sprite").set_opacity(self.default_opacity)
	
func _mouse_entered():
	get_node("SamplePlayer").play("tile_hover")
	get_node("Sprite").set_opacity(self.highlight_opacity)
	#we needed this in case you exited from a tile and it reset AFTER another tile called predict lol
#	get_node("Timer").set_wait_time(0.01)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	get_parent().predict(self.coords)

func _mouse_exited():
	get_node("Sprite").set_opacity(self.default_opacity)
	if get_parent().selected != null:
		get_parent().reset_prediction()
	
func star_input_event(event):
	if self.corpse != null and !get_parent().pieces.has(coords):
		self.corpse.resurrect()
		self.corpse = null
		return true
	
	return false

	
func input_event(event, has_selected):
	get_parent().set_target(self)

func external_set_opacity(value=self.highlight_opacity):
	get_node("Sprite").set_opacity(value)
	
func get_size():
	return get_node("Sprite").get_item_rect().size