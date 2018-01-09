extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var index = 0
var dead_heroes
var revive_pos
var coords
var active

signal selected

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Left").connect("pressed", self, "swap", [-1])
	get_node("Right").connect("pressed", self, "swap", [1])
	

func handle(coords):
	self.coords = coords
	self.revive_pos = get_parent().locations[coords].get_pos()
	set_pos(self.revive_pos)
	show()
	self.dead_heroes = get_tree().get_nodes_in_group("dead_heroes")
	var current_option = dead_heroes[0]
	current_option.set_pos(self.revive_pos)
	current_option.animate_possible_revive()
	get_node("Timer").set_wait_time(0.1)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	set_pickable(true)
	

func swap(increment):
	var selector = self.index % dead_heroes.size()
	var current_option = self.dead_heroes[selector]
	current_option.set_opacity(0)
	current_option.set_pos(Vector2(-200, -200))
	self.index += increment
	selector = self.index % dead_heroes.size()
	print(self.index)
	print(selector)
	var current_option = self.dead_heroes[selector]
	print("current option:", current_option.unit_name)
	current_option.set_opacity(1)
	print("revive pos: ", self.revive_pos)
	current_option.set_pos(self.revive_pos)
	print("current pos: ", current_option.get_pos())
	print("swapping")
	current_option.animate_possible_revive()
	
	
func _input_event(viewport, event, shape_idx):
	if get_node("/root/InputHandler").is_select(event):
		print("triggered input event")
		emit_signal("selected", self.dead_heroes[index % dead_heroes.size()], coords)
		self.index = 0
		self.dead_heroes = null
		self.revive_pos = null
		self.coords = null
		set_pickable(false)
		hide()