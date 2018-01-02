extends "res://UI/TextureLabelButton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var level = null

func initialize(level, score, disabled=false):
	self.level = level
	get_node("Toppings/Label").set_text(self.level.name.to_upper())
	if score != null:
		get_node("Toppings/SmallScoreStars").display_score(score)
	if disabled:
		set_disabled(true)


func is_pressed():
	emit_signal("pressed", self.level)