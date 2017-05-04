extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const STATES = {"unit_select":0, "target_select":1}

var state = self.STATES.unit_select

var unit_coords

var unit_text

var target_coords

var target_text


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(unit_coords, unit_text, target_coords, target_text):
	self.unit_coords = unit_coords
	self.unit_text = unit_text
	self.target_coords = target_coords
	self.target_text = target_text


func display_current_phase():
	pass

	
func move_is_valid(coords):
	if self.state == self.STATES.unit_select:
		if coords == self.unit_coords:
			self.state = self.STATES.target_select
			get_parent().update_display_forced_action(self.target_coords, self.target_text)
			return true
		else:
			return false
			
	elif self.state == self.STATES.target_select:
		if coords == self.target_coords:
			get_parent().finish_forced_action()
			return true
		else:
			return false
			
func get_coords():
	if self.state == self.STATES.unit_select:
		return self.unit_coords
	elif self.state == self.STATES.target_select:
		return self.target_coords
		
func get_text():
	if self.state == self.STATES.unit_select:
		return self.unit_text
	elif self.state == self.STATES.target_select:
		return self.target_text
	