extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal done
signal next

func _ready():
	# Called every time the node is added to the scene.
	# Initialization
	get_node("Panel/TextureButton").set_disabled(true)
	get_node("Panel/TextureButton").connect("pressed", self, "button_pressed")
	get_node("Panel/TipText").set_bbcode("")
	get_node("Panel/ObjectiveText").set_bbcode("")

func button_pressed():
	emit_signal("next")
	
func transition_in():
	get_node("Tween").interpolate_property(get_node("Panel/TipText"), "visibility/opacity", 0, 1, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Tween").interpolate_property(get_node("Panel/ObjectiveText"), "visibility/opacity", 0, 1, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	get_node("Panel/TextureButton").set_disabled(false)
	get_node("Tween").interpolate_property(get_node("Panel/TextureButton"), "visibility/opacity", 0, 1, 0.4, Tween.TRANS_SINE, Tween.EASE_IN)
	get_node("Tween").start()
	yield(get_node("Tween"), "tween_complete")
	emit_signal("done")
	
func transition_out():
	get_node("Panel/TipText").set_opacity(0)
	get_node("Panel/ObjectiveText").set_opacity(0)
	get_node("Panel/ObjectiveText").set_pos(Vector2(30, 122))
	get_node("Panel/TextureButton").set_opacity(0)
	get_node("Panel/TextureButton").set_disabled(true)
	
func set_text(tip, objective):

	var objective_text = ""
	if objective: #only set objective text if there is any
		objective_text = "[color=red][b]OBJECTIVE: [/b][/color]" + objective
	
	if !tip: #if no tip, move objective text to the top
		get_node("Panel/ObjectiveText").set_bbcode(objective_text)
		get_node("Panel/ObjectiveText").set_pos(Vector2(30, 30))
	else: #handle the case where there's both tip and objective
		var tip_text = "[color=yellow][b]RULE: [/b][/color]" + tip
		get_node("Panel/TipText").set_bbcode(tip_text)
		get_node("Panel/ObjectiveText").set_bbcode(objective_text)
