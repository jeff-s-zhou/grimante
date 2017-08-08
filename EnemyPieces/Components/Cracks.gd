extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var crack_variant 

var cracked = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	randomize()
	#self.crack_variant = randi() % 3
	self.crack_variant = 1 #TODO: make 2 more variants
	

func crack():
	#get_node("AnimatedSprite").show()
	get_node("AnimationPlayer").play("crack")
	#if !cracked:
#		get_node("AnimatedSprite").set_frame(self.crack_variant)
#		get_node("AnimatedSprite").show()
#		self.cracked = true
#	else:
#		get_node("AnimatedSprite").set_animation("end")
#		get_node("AnimatedSprite").set_frame(self.crack_variant)