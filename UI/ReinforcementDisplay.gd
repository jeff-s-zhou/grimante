extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var waves_display = []

var full_circle_resource = preload("res://Assets/UI/reinforcements_full_circle.png")
var half_circle_resource = preload("res://Assets/UI/reinforcements_half_circle.png")
var empty_circle_resource = preload("res://Assets/UI/reinforcements_empty_circle.png")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func display_waves(wave_power_levels, horde_threshold):
	wave_power_levels.pop_front()
	for power_level in wave_power_levels:
		var circle = Sprite.new()
		
		if power_level == 0:
			circle.set_texture(empty_circle_resource)
		elif power_level > horde_threshold:
			circle.set_texture(full_circle_resource)
		else:
			circle.set_texture(half_circle_resource)
		
		self.waves_display.append(circle)
		circle.set_pos(Vector2(get_pos().x + 30 * self.waves_display.size(), get_pos().y))
		add_child(circle)

func update_waves():
	var circle = self.waves_display[0]
	self.waves_display.pop_front()
	circle.queue_free()
	
	
func recenter():
	pass
	