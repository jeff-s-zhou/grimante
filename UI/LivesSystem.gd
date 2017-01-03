extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var life_prototype = preload("Life.tscn")
var lives_list = []
var lives = 0

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func set_lives(amount):
	self.lives = amount
	for i in range(0, amount):
		var life = life_prototype.instance()
		life.set_pos(Vector2(34 + i * 75, 76))
		add_child(life)
		self.lives_list.append(life)
		
		
func lose_lives(amount):
	self.lives -= amount
	get_node("/root/AnimationQueue").enqueue(self, "animate_lose_lives", true, [amount])
	
	
func animate_lose_lives(amount):
	var lost_lives = []
	for i in range(self.lives_list.size() - amount, self.lives_list.size()):
		self.lives_list[i].get_node("AnimationPlayer").play("Flicker")
		lost_lives.append(self.lives_list[i])
	for i in range(0, amount):
		self.lives_list.pop_back()
	yield(lost_lives[0].get_node("AnimationPlayer"), "finished")
	for i in range(0, lost_lives.size()):
		lost_lives[i].queue_free() 
	emit_signal("animation_done")


	
func gain_lives(amount):
	#TODO
	pass
