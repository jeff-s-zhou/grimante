extends "res://UI/TransitionHelper.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func compare_y(first, second):
	return int(first.get_name()) < int(second.get_name())
