extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var kill_count = 0

const KILL_LIMIT = 7

signal add_star

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func reset():
	self.kill_count = 0
	get_node("/root/AnimationQueue").enqueue(self, "animate_add_kill_count", false, [self.kill_count])
	
func add_kill_count():
	self.kill_count += 1
	if self.kill_count == KILL_LIMIT:
		self.kill_count = 0
		emit_signal("add_star")
	get_node("/root/AnimationQueue").enqueue(self, "animate_add_kill_count", false, [self.kill_count])
	

func animate_add_kill_count(kill_count):
	get_node("TextureProgress").set_value(kill_count)
	get_node("Label").set_text(str(kill_count) + "/7")