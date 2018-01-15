extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var line_start
var line_end
var line_distance
var full_length

const DIAMOND = preload("res://Assets/effects/light_chain_diamond.png")
const CIRCLE = preload("res://Assets/effects/light_chain_dot.png")

var unit_distance = 15

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#draw_dotted(Vector2(150, 150), Vector2(150, 450))
	
	#set_process(true)
	pass
	

func draw_chains(s, e):
	set_opacity(0)
	var start_pos = s #+ Vector2(0, -15)
	var end_pos = e #+ Vector2(0, -15)
	print("drawing chains")
	#print(start_pos + Vector2(0, -15))
	#print(end_pos + Vector2(0, -15))
	var length = (end_pos - start_pos).length()
	var angle = start_pos.angle_to_point(end_pos)
	draw_dotted(length)
	print(angle)
	set_rot(angle + PI)
	translate(Vector2(0, -14))
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("Tween").start()
	get_node("/root/Combat").darken(0.2, 0.1)
	yield(get_node("Tween"), "tween_complete")
	get_node("Timer").set_wait_time(0.1)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	get_node("/root/Combat").lighten(0.2)
	

func explode():
	self.line_distance = null
	update()
	queue_free()

#NOTE only draws downwards actually, so you'll have to rotato
func draw_dotted(length):
	self.line_start = Vector2(0, 0) + Vector2(-13, -15)#vector
	self.line_end = Vector2(0, length) + Vector2(-13, -15) #vector
	self.line_distance = (self.line_end - self.line_start) + Vector2(0, 30) #vector
	self.unit_distance = calculate_unit_distance(line_distance) #vector
	update()
	
func _draw():
	if self.line_distance != null:
		var amount_of_circles = round(self.line_distance.length()/self.unit_distance.length())
		var current_pos = self.line_start
		for i in range(0, amount_of_circles):
			draw_texture(CIRCLE, current_pos)
			if i != amount_of_circles - 1:
				draw_texture(DIAMOND, current_pos + self.unit_distance/2)
			current_pos += self.unit_distance


#tries to figure out how many things to draw and how much to space them out by
func calculate_unit_distance(distance):
	var shortest_unit = 23
	var furthest_unit = 28
	var unit_length = get_cleanest_divisor(shortest_unit, furthest_unit, distance.length())
	return distance.normalized() * unit_length


func get_cleanest_divisor(shortest, furthest, length):
	var current_cleanest_divisor
	var current_lowest_difference = 999999.0
	
	for i in range(shortest, furthest + 1):
		var amount = length / i
		var below_difference = amount - floor(amount)
		var above_difference = ceil(amount) - amount
		var difference = min(above_difference, below_difference)
		
		if difference < current_lowest_difference:
			current_lowest_difference = difference
			current_cleanest_divisor = i
	return current_cleanest_divisor
