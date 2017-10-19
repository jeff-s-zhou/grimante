extends "res://UI/TextureLabelButton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func set_disabled(flag):
	var color = Color(109, 109, 109)
	get_node("Toppings/Label").set("custom_colors/font_color", color)
	.set_disabled(flag)