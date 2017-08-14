extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var star_count = 0
var enabled = true
var star_add_pos = Vector2(42, 43)

var stars = []

func _ready():
	get_node("TextureButton").connect("pressed", self, "is_pressed")
	
func disable():
	self.hide()
	self.enabled = false

#used to temporarily disable during pause screens and stuff
func set_disabled(flag):
	self.enabled = !flag

func has_star():
	return self.star_count > 0

func add_star():
	print("adding star?")
	if self.enabled and self.star_count < 3:
		self.star_count += 1
		get_node("TextureButton").set_disabled(false)
		get_node("/root/AnimationQueue").enqueue(self, "animate_add_star", false, [self.star_count])
		
func refund():
	add_star()
	
func animate_add_star(count):
	var star_texture = load("res://Assets/UI/star_power_star_big.png")
	var star = Sprite.new()
	star.set_texture(star_texture)
	star.set_pos(self.star_add_pos)
	self.star_add_pos += Vector2(62, 0)
	add_child(star)
	self.stars.append(star)
	
	
func animate_remove_star(count):
	var star = self.stars[self.stars.size() - 1]
	self.stars.pop_back()
	self.star_add_pos -= Vector2(62, 0)
	star.queue_free()


func is_pressed():
	if self.star_count > 0:
		get_node("/root/Combat").set_active_star(true)
		self.star_count -= 1
		get_node("/root/AnimationQueue").enqueue(self, "animate_remove_star", false, [self.star_count])
		if self.star_count == 0:
			get_node("TextureButton").set_disabled(true)