extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

var coords

var grid

#STATE
var raining = false
var deployable = false

var reinforcement = null
var laid_trap = false
var armed_trap = false

var revivable = false

var default_opacity = 0.2

var highlight_opacity = 0.7

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
	self.grid = get_parent()
	
func soft_reset():
	set_rain(false)
	set_deployable_indicator(false)
	
func debug():
	if get_node("Coords").is_visible():
		get_node("Coords").hide()
	else:
		get_node("Coords").show()
		get_node("Coords/Label").set_text(str(coords.x) + "," + str(coords.y))

func hide_indirect_highlighting():
	self.indirect_highlighting = false
	
func set_coords(coords):
	self.coords = coords
	
func set_endzone():
	get_node("EndzoneHighlight").show()
	
func set_targetable(flag):
	if flag:
		#set_opacity(self.highlight_opacity)
		set_pickable(true)
	else:
		#set_opacity(self.default_opacity)
		set_pickable(false)

func is_targetable():
	return self.is_pickable()
	
func set_reinforcement(reinforcement):
	self.reinforcement = reinforcement
	
func is_trapped():
	return self.armed_trap
	
func set_trap():
	self.laid_trap = true
	
func trigger_trap():
	print("triggering trap")
	get_node("/root/AnimationQueue").enqueue(self, "animate_trigger_trap", true)
	self.armed_trap = false

#do we just want to do the flashing light again? No that doesn't work...
#also in that case, the animation for when it procs from summoning might be different?
func animate_trigger_trap():
	get_node("/root/AnimationQueue").update_animation_count(1)
	get_node("TrapSymbol").animate_explode()
	yield(get_node("TrapSymbol"), "animation_done")
	emit_signal("animation_done")
	get_node("/root/AnimationQueue").update_animation_count(-1)



func deploy_enemy(animation_speed, first=false):
	if self.reinforcement != null:
		if !first:
			get_node("/root/AnimationQueue").enqueue(self, "animate_reinforcement_summon", true, [animation_speed])
		
		if self.grid.pieces.has(coords):
			var blocking_piece = self.grid.pieces[coords]
			if blocking_piece.side == "PLAYER":
				blocking_piece.block_summon()
				self.reinforcement.queue_free()
			else:
				blocking_piece.summon_buff(self.reinforcement.hp, self.reinforcement.get_modifiers())
				self.reinforcement.queue_free()
				
		else:
			self.grid.add_piece(coords, self.reinforcement, true)
			
		self.reinforcement = null


func arm_trap(first=false):
	if self.laid_trap:
		if !first:
			get_node("/root/AnimationQueue").enqueue(self, "animate_arm_trap", true)
		else:
			get_node("TrapSymbol").show()
	
		if self.grid.pieces.has(coords):
			var blocking_piece = self.grid.pieces[coords]
			if blocking_piece.side == "PLAYER":
				blocking_piece.block_summon()
			else:
				blocking_piece.trap_buff()
			get_node("TrapSymbol").hide() #trap is already consumed, 
		else:
			self.armed_trap = true
			
		self.laid_trap = false
		
func display_incoming():
	get_node("/root/AnimationQueue").enqueue(self, "animate_display_reinforcement", false)
	get_node("/root/AnimationQueue").enqueue(self, "animate_display_laid_trap", false)
	
func animate_display_reinforcement():
	if self.reinforcement != null:
		set_reinforcement_indicator(self.reinforcement.type)
		
func animate_display_laid_trap():
	if self.laid_trap:
		get_node("ReinforcementIndicator").display("trap")
		get_node("ReinforcementIndicator").show()

		
func set_revivable(flag):
	self.revivable = flag
	if flag:
		get_node("ReviveSymbol").show()
	else:
		get_node("ReviveSymbol").hide()


func set_reinforcement_indicator(type=null):
	if type != null:
		get_node("ReinforcementIndicator").display(type)
		get_node("ReinforcementIndicator").show()
	else:
		get_node("ReinforcementIndicator").hide()
		
		
func animate_arm_trap():
	get_node("ReinforcementIndicator").animate_summon()
	yield(get_node("ReinforcementIndicator"), "animation_done")
	emit_signal("animation_done")
	if self.reinforcement == null:
		set_reinforcement_indicator(null)
	get_node("TrapSymbol").show()

func animate_reinforcement_summon(animation_speed):
	get_node("ReinforcementIndicator").animate_summon(animation_speed)
	yield(get_node("ReinforcementIndicator"), "animation_done")
	emit_signal("animation_done")
	if self.reinforcement == null:
		set_reinforcement_indicator(null)
	
func play_summon_sound():
	get_node("SamplePlayer").play("summon4")
		
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
	get_node("HighlightSprite").show()

	
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
	#print("mouse_entered")
	get_node("SamplePlayer").play("magic tile hover")
	get_node("Sprite").set_opacity(self.highlight_opacity)
	#we needed this in case you exited from a tile and it reset AFTER another tile called predict lol
#	get_node("Timer").set_wait_time(0.005)
#	get_node("Timer").start()
#	yield(get_node("Timer"), "timeout")
	self.grid.predict(self.coords)
#	var hovered = get_node("/root/Combat").get_hovered() #if we're staying on the tile, predict
#	print("hovered in mouse_entered", hovered)
#	if hovered == self:
#		print("matched self, which is ", self)
#		self.grid.predict(self.coords)

func _mouse_exited():
	#print("mouse exited")
	get_node("Sprite").set_opacity(self.default_opacity)
	if self.grid.selected != null:
		self.grid.reset_prediction()

#
func star_input_event(event):
	if self.revivable:
		return self.grid.handle_revive(self.coords)
	return false

	
func input_event(event, has_selected):
	self.grid.set_target(self)

func external_set_opacity(value=self.highlight_opacity):
	get_node("Sprite").set_opacity(value)
	
func get_size():
	return get_node("Sprite").get_item_rect().size