extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal finished

var selected_modifiers = {} #represented as modifier_name:boolean, so we can easily toggle the value

onready var enemy_modifiers = get_node("/root/constants").enemy_modifiers

var modifier_mock_prototype = preload("res://LevelEditor/ModifierMock.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Button").connect("pressed", self, "form_finished")
	
	var x_pos = 60
	
	for modifier in enemy_modifiers:
		var modifier_mock = modifier_mock_prototype.instance()
		add_child(modifier_mock)
		modifier_mock.initialize(modifier)
		modifier_mock.set_pos(Vector2(x_pos, 150))
		self.selected_modifiers[modifier] = false
		x_pos += 115
		
func reset_modifiers():
	for modifier in enemy_modifiers:
		self.selected_modifiers[modifier] = false

func toggle_modifier(modifier):
	selected_modifiers[modifier] = !selected_modifiers[modifier]
	
func form_finished():
	var text = get_node("LineEdit").get_text()
	var cleaned_modifiers = {} #only return the ones set to true
	for modifier in self.selected_modifiers:
		if self.selected_modifiers[modifier]:
			cleaned_modifiers[modifier] = true
	emit_signal("finished", text, cleaned_modifiers)
	self.hide()
	get_node("LineEdit").clear()
	reset_modifiers()