extends "res://UI/TextureLabelButton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var level_set = null

func initialize(level_set):
	self.level_set = level_set
	var unlocked = get_node("/root/State").is_set_unlocked(level_set.id)
	set_disabled(!unlocked)
	get_node("Toppings/Label").set_text(str(self.level_set.id))


func is_pressed():
	emit_signal("pressed", self.level_set)