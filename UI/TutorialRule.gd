extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var text_list

var index = 0

var associated_graphics_dict

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func initialize(text_list, associated_graphics_dict={}):
	self.text_list = text_list
	self.associated_graphics_dict = associated_graphics_dict
	
func get_index():
	return self.index

func get_size():
	return self.text_list.size()
	
func get_next_line():
	if self.index < self.text_list.size():
		var text = self.text_list[self.index]
		if self.associated_graphics_dict.has(self.index):
			var associated_graphic = self.associated_graphics_dict[self.index]
			self.index += 1
			return [text, associated_graphic]
		else:
			self.index += 1
			return text
	else:
		return null

