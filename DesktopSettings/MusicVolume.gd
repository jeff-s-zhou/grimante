extends "Setting.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	var scale = Globals.get("audio/stream_volume_scale")
	get_node("HSlider").set_value(scale)
	get_node("HSlider").connect("value_changed", self, "update_volume")


#goes from 0 to 2, 1 is default
func update_volume(value):
	AudioServer.set_stream_global_volume_scale(value)
	Globals.set("audio/stream_volume_scale", value)
	Globals.save()