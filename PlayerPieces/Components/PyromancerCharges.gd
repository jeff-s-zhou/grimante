extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var charges = 4

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Label").set_text(str(self.charges))

func add_charge(amount=1):
	self.charges += 1
	get_node("/root/AnimationQueue").enqueue(self, "animate_add_charge", false)

func animate_add_charge():
	get_node("Label").set_text(str(self.charges))
	
func get_charge():
	if self.charges > 0:
		self.charges -= 1
		get_node("/root/AnimationQueue").enqueue(self, "animate_get_charge", false, [self.charges])
		return true
		
	else:
		return false
	

func animate_get_charge(value):
	print("animating get charge: ", value)
	get_node("Label").set_text(str(value))