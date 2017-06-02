extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const RulePrototype = preload("res://UI/TutorialRule.tscn")

const STATES = {"unit_select":0, "target_select":1, "result":2}

var state = self.STATES.unit_select

var unit_coords

var unit_text

var target_coords

var target_text

var result_rule


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(unit_coords, unit_text, target_coords, target_text, result_text_list=null):
	self.unit_coords = unit_coords
	self.unit_text = unit_text
	self.target_coords = target_coords
	self.target_text = target_text
	if result_text_list != null:
		var result_rule = RulePrototype.instance()
		result_rule.initialize(result_text_list)
		self.result_rule = result_rule


func display_current_phase():
	pass

	
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


func get_next_state():
	if self.state == self.STATES.unit_select:
		self.state = self.STATES.target_select
		return [self.target_coords, self.target_text]
	elif self.state == self.STATES.target_select:
		return self.result_rule

			
func get_coords():
	if self.state == self.STATES.unit_select:
		return self.unit_coords
	elif self.state == self.STATES.target_select:
		return self.target_coords
		
func get_text():
	if self.state == self.STATES.unit_select:
		return self.unit_text
	elif self.state == self.STATES.target_select:
		#if we just want one message for both parts of the forced action
		if self.target_text == "" or self.target_text == null:
			return self.unit_text
		else:
			return self.target_text
	