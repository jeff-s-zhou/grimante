extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var index = 1
var active = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	for i in range(1, 8):
		var name = str(i)
		get_node(name).set_opacity(0)
		
		

func increase():
	if self.index < 8:
		if self.index == 7:
			self.active = true
		get_node("/root/AnimationQueue").enqueue(self, "animate_increase", false, [self.index])
		self.index += 1

#add a full star
func max_out():
	self.active = true
	self.index = 7
	get_node("/root/AnimationQueue").enqueue(self, "animate_max", false)
		
func animate_max():
	var tween = get_node("Tween")
	for i in range(1, 8):
		var star_part = get_node(str(i))
		tween.interpolate_property(star_part, "visibility/opacity", star_part.get_opacity(), 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_complete")
	
	tween.interpolate_property(get_node("Full"), "visibility/opacity", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(get_node("Glow"), "visibility/opacity", 0, 1, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	get_parent().play_star_charged()
	yield(tween, "tween_complete")
	yield(tween, "tween_complete")
	tween.interpolate_property(get_node("Glow"), "visibility/opacity", 1, 0, 1.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.6)
	tween.start()

func animate_increase(i):
	if i < 8:
		print(i)
		var star_part = get_node(str(i))
		var tween = get_node("Tween")
		tween.interpolate_property(star_part, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_complete")
		
		if i == 7:
			
			tween.interpolate_property(get_node("Full"), "visibility/opacity", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.interpolate_property(get_node("Glow"), "visibility/opacity", 0, 1, 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
			get_parent().get_node("SamplePlayer").play("star_charged")
			yield(tween, "tween_complete")
			yield(tween, "tween_complete")
			tween.interpolate_property(get_node("Glow"), "visibility/opacity", 1, 0, 1.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.6)
			tween.start()

func flash(flag):
	if self.active:
		if flag:
			get_node("AnimationPlayer").play("glow_flash")
		else:
#			if get_node("AnimationPlayer").is_playing():
#				yield(get_node("AnimationPlayer"), "finished")
			get_node("AnimationPlayer").stop(true)
	