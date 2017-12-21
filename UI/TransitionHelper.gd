extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var original_positions = {}

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func get_sliding_children():
	var children = get_children()
	children.erase(get_node("Tween"))
	children.erase(get_node("Timer"))
	children.sort_custom(self, "compare_y")
	return children
	
func initialize():
	for node in get_sliding_children():
		if node.has_method("get_pos"):
			node.set_opacity(0)
			self.original_positions[node] = node.get_pos()
	
	
func animate_slide_out():
	var nodes = get_sliding_children()
	var delay = 0.0
	for node in nodes:
		if node.has_method("get_pos"):
			var start_pos = node.get_pos()
			var end_pos = node.get_pos() + Vector2(-300, 0)
			animate_individual_slide_out(node, start_pos, end_pos, delay)
			delay += 0.05
	get_node("Tween").start()
	get_node("Timer").set_wait_time(delay + 0.20)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")

func animate_slide_in():
	var nodes = get_sliding_children()
	var delay = 0.0
	for node in nodes:
		if node.has_method("get_pos"):
			var end_pos = self.original_positions[node]
			var start_pos = end_pos + Vector2(300, 0)
			animate_individual_slide_in(node, start_pos, end_pos, delay)
			delay += 0.05
	get_node("Tween").start()
	get_node("Timer").set_wait_time(delay + 0.20)
	get_node("Timer").start()
	yield(get_node("Timer"), "timeout")
	emit_signal("animation_done")
	
func compare_y(first, second):
	return first.get_pos().y < second.get_pos().y
	
func animate_individual_slide_in(node, start_pos, end_pos, delay):
	var tween = get_node("Tween")
	var pos_property = "transform/pos"
	if "rect/pos" in node:
		pos_property = "rect/pos"
	tween.interpolate_property(node, "visibility/opacity", 0, 1, 0.20, Tween.TRANS_LINEAR, Tween.EASE_OUT, delay)
	tween.interpolate_property(node, pos_property, start_pos, end_pos, 0.20, Tween.TRANS_QUAD, Tween.EASE_OUT, delay)


func animate_individual_slide_out(node, start_pos, end_pos, delay):
	var tween = get_node("Tween")
	var pos_property = "transform/pos"
	if "rect/pos" in node:
		pos_property = "rect/pos"
	tween.interpolate_property(node, "visibility/opacity", 1, 0, 0.20, Tween.TRANS_LINEAR, Tween.EASE_OUT, delay)
	tween.interpolate_property(node, pos_property, start_pos, end_pos, 0.20, Tween.TRANS_QUAD, Tween.EASE_OUT, delay)