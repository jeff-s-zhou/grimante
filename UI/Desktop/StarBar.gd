extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var star_count = 0
var enabled = true
var star_add_pos = Vector2(38, 39)

const STAR_SHIFT = Vector2(52, 0)

var star_prototype = load("res://UI/Desktop/Star.tscn")

var inactive_star

var stars = []

func _ready():
	get_node("TextureButton").connect("pressed", self, "is_pressed")
	
func handle_enemy_death():
	if enabled:
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
	self.star_count += 1
	var star = self.star_prototype.instance()
	star.set_pos(self.star_add_pos)
	self.inactive_star = star
	add_child(star)
	self.stars.append(star)
	self.inactive_star.max_out() #increase to a full star
	self.star_add_pos += STAR_SHIFT
	get_node("TextureButton").set_disabled(false)
	self.inactive_star = null
	
func animate_remove_star(count):
	var consumed_star = self.stars[0]
	self.stars.pop_front()
	consumed_star.queue_free()
	
	
	#shift everything right
	for star in self.stars:
		star.set_pos(star.get_pos() - STAR_SHIFT)
	self.star_add_pos -= STAR_SHIFT
	
	
func disable():
	self.hide()
	self.enabled = false

#used to temporarily disable during pause screens and stuff
func set_disabled(flag):
	self.enabled = !flag

func has_star():
	return self.star_count > 0
		
func refund():
	add_star()


func is_pressed():
	if self.star_count > 0:
		get_node("/root/Combat").set_active_star(true)
		self.star_count -= 1
		get_node("/root/AnimationQueue").enqueue(self, "animate_remove_star", false, [self.star_count])
		if self.star_count == 0:
			get_node("TextureButton").set_disabled(true)