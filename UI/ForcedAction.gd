extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const RulePrototype = preload("res://UI/TutorialRule.tscn")

const STATES = {"unit_select":0, "target_select":1, "result":2}

var state = self.STATES.unit_select

var unit_coords

var target_coords

var arrow_flag

var result_rule

var text


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(unit_coords, target_coords, result_text_list=null, display_arrow=true, text=null):
	self.arrow_flag = display_arrow
	self.unit_coords = unit_coords
	self.target_coords = target_coords
	self.text = text
	if result_text_list != null:
		var result_rule = RulePrototype.instance()
		result_rule.initialize(result_text_list)
		self.result_rule = result_rule


func display_current_phase():
	pass

func update():
	if self.state == self.STATES.unit_select:
		self.state = self.STATES.target_select
	elif self.state == self.STATES.target_select:
		self.state = self.STATES.result
	
func move_is_valid(coords, turn):
	if self.state == self.STATES.unit_select:
		if coords == self.unit_coords:
			return true
		else:
			return false
	elif self.state == self.STATES.target_select:
		if coords == self.target_coords:
			return true
		else:
			return false


func is_finished():
	return self.state == self.STATES.result
	
func has_arrow():
	return self.arrow_flag
	
func has_result():
	return self.result_rule != null
	
func has_text():
	return self.text != null
	
func get_initial_coords():
	return self.unit_coords

func get_final_coords():
	return self.target_coords
