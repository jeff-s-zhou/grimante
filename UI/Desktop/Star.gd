extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var index = 0
var active = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	for i in range(1, 8):
		var name = str(i)
		get_node(name).set_opacity(0)
		
		

func increase():
	if self.index < 7:
		self.index += 1
		if self.index == 7:
			self.active = true
		get_node("/root/AnimationQueue").enqueue(self, "animate_increase", false, [self.index])


#add a full star
func max_out():
	self.active = true
	for i in range(1, 8):
		get_node("/root/AnimationQueue").enqueue(self, "animate_increase", false, [i])


func animate_increase(index):
	if index < 8:
		var star_part = get_node(str(index))
		get_node("Tween").interpolate_property(star_part, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
		get_node("Tween").start()
		yield(get_node("Tween"), "tween_complete")
		
		if index == 7:
			get_node("Tween").interpolate_property(get_node("Full"), "visibility/opacity", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
			get_node("Tween").interpolate_property(get_node("Glow"), "visibility/opacity", 0, 1, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			get_node("Tween").start()
			yield(get_node("Tween"), "tween_complete")
			yield(get_node("Tween"), "tween_complete")
			get_node("Tween").interpolate_property(get_node("Glow"), "visibility/opacity", 1, 0, 1.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.6)
			get_node("Tween").start()
			
func flash(flag):
	if self.active:
		if flag:
			get_node("AnimationPlayer").play("glow_flash")
		elif get_node("AnimationPlayer").is_playing():
			yield(get_node("AnimationPlayer"), "finished")
			get_node("AnimationPlayer").stop_all()
	