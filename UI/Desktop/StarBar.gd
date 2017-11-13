extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var star_count = 0
var enabled = true

var temp_enabled = true

const FRONT_POS = Vector2(38, 39)
var star_add_pos = Vector2(38, 39)

const STAR_SHIFT = Vector2(52, 0)

var star_prototype = load("res://UI/Desktop/Star.tscn")

var has_active_star #currently spent, about to be used

var inactive_star

var stars = []

func _ready():
	get_node("TextureButton").connect("pressed", self, "is_pressed")
	
func handle_enemy_death():
	if enabled and temp_enabled:
		if self.inactive_star != null:
			self.inactive_star.increase()
			#became active
			if self.inactive_star.active:
				self.inactive_star = null
				self.star_count += 1
				get_node("TextureButton").set_disabled(false)
		else:
			add_inactive_star()

func add_inactive_star():
	if self.enabled and self.star_count < 3:
		var star = self.star_prototype.instance()
		star.set_pos(self.star_add_pos)
		self.inactive_star = star
		add_child(star)
		self.stars.append(star)
		self.inactive_star.increase() #calls its own animation
		self.star_add_pos += STAR_SHIFT


#adds a full star, used for tutorial and debug purposes
func add_star():
	if enabled:
		if self.star_count == 3:
			self.inactive_star.max_out()
		else:
			refund()
	
func animate_remove_star(count):
	var consumed_star = self.stars[0]
	self.stars.pop_front()
	consumed_star.queue_free()
	
	
	#shift everything right
	for star in self.stars:
		star.set_pos(star.get_pos() - STAR_SHIFT)
	self.star_add_pos -= STAR_SHIFT
	
#
func disable():
	self.hide()
	self.enabled = false

#used to temporarily disable during pause screens and stuff
func set_temp_disabled(flag):
	self.temp_enabled = !flag

func has_star():
	return self.star_count > 0
		
func refund():
	for star in self.stars:
		star.set_pos(star.get_pos() + STAR_SHIFT)
	self.star_add_pos += STAR_SHIFT
	
	self.star_count += 1
	var star = self.star_prototype.instance()
	star.set_pos(FRONT_POS)
	print("is this the buggy area")
	add_child(star)
	print("ending buggy area")
	self.stars.push_front(star)

	star.max_out() #increase to a full star
	get_node("TextureButton").set_disabled(false)
	
	
func set_active_star(flag):
	get_node("/root/Combat/CursorArea").set_star_cursor(flag)
	self.has_active_star = flag
	

func handle_active_star(hovered, event):
	if self.has_active_star:
		set_active_star(false)
		var successful = hovered.star_input_event(event)
		if !successful:
			refund()
		return true
	return false


func is_pressed():
	if self.star_count > 0:
		set_active_star(true)
		self.star_count -= 1
		get_node("/root/AnimationQueue").enqueue(self, "animate_remove_star", false, [self.star_count])
		if self.star_count == 0:
			get_node("TextureButton").set_disabled(true)
			
	
func star_flash(flag):
	for star in self.stars:
		star.flash(flag)