extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var remaining_tooltips = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
	
func _input(event):
	if event.is_action("select") and event.is_pressed(): 
		if self.remaining_tooltips.size() > 0:
			var tooltip = self.remaining_tooltips[0]
			self.remaining_tooltips.pop_front()
			tooltip_helper(tooltip)

func set_tooltip(tooltip):
	if tooltip["coords"] != null:
		tooltip_helper(tooltip)
		
func set_tooltips(tooltips):
	var tooltip = tooltips[0]
	tooltips.pop_front()
	set_process_input(true)
	self.remaining_tooltips = tooltips
	tooltip_helper(tooltip)


func tooltip_helper(tooltip):
	show()
	var coords = tooltip["coords"]
	var new_pos = get_parent().get_node("Grid").locations[coords].get_global_pos()
	set_pos(new_pos)
	
	if tooltip["text"]:
		get_node("Panel/Text").set_bbcode(tooltip["text"])
		get_node("Panel").show()


func reset():
	self.hide()
	get_node("Panel").hide()
	get_node("Panel/Text").set_bbcode("")
	set_process_input(false)
	