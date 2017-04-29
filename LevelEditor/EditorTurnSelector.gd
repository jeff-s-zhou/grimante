extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var turn_icon_prototype = preload("res://LevelEditor/TurnIcon.tscn")

var turn_count = 9

var turn_icons = []

signal selected(turn_number)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var x_pos = 135
	for i in range(0, turn_count):
		var turn_icon = self.turn_icon_prototype.instance()
		turn_icon.initialize(i)
		turn_icon.set_z(99)
		turn_icon.set_pos(Vector2(x_pos, 35))
		turn_icon.connect("selected", self, "select")
		self.turn_icons.append(turn_icon)
		add_child(turn_icon)
		x_pos += 50

func select(turn_number):
	for turn_icon in turn_icons:
		turn_icon.deselect()
	turn_icons[turn_number].select()
	
	emit_signal("selected", turn_number)
	