extends "QuickButton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var sound_flag = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	#connect("input_event", self, "handle_click")
	#set_process_input(true)

func _input_event(viewport, event, shape_idx):
	if get_node("/root/InputHandler").is_select(event):
		self.sound_flag = !self.sound_flag
		get_node("/root/MusicPlayer").set_paused(!self.sound_flag)
		
		if !self.sound_flag:
			AudioServer.set_fx_global_volume_scale(0)
			get_node("AnimatedSprite").play("off")
		else:
			AudioServer.set_fx_global_volume_scale(0.3)
			get_node("AnimatedSprite").play("on")
			
	