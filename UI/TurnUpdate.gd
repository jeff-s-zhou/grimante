extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal animation_done
var start_pos = Vector2(-512, -300)
var end_pos = Vector2(-512, -260)

var turn_limit = 0
var current_turn = 0

var name

var has_previous_score

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_opacity(0)
	pass
	
func initialize(level_schematic):
	self.turn_limit = level_schematic.num_turns
	self.name = level_schematic.name
	var score = get_node("/root/State").get_level_score(level_schematic.id)
	self.has_previous_score = score != null and score != 5
	if self.has_previous_score: #already attempted but not full score
		var turn = level_schematic.get_turn_to_improve_score(score)
		if turn == 1:
			get_node("TurnSubtext").set_bbcode(
			"[center]CLEAR IN [color=#00ffcc]" + str(turn) + "[/color] TURN TO BEAT YOUR SCORE[/center]")
		else:
			get_node("TurnSubtext").set_bbcode(
			"[center]CLEAR IN [color=#00ffcc]" + str(turn) + "[/color] TURNS TO BEAT YOUR SCORE[/center]")
		
		
	

func animate_player_phase(current_turn):
	animate(current_turn, false)
	
func animate_enemy_phase(current_turn):
	animate(current_turn, true)

#enemy phase: 1.2 secs
#player phase: 1.7 secs
#final player phase: 1.7 + 1.6 secs
func animate(current_turn, enemy_phase=false):
	
	set_phase(current_turn, enemy_phase)
	get_parent().blur_darken(0.2)
	get_node("Tween").interpolate_property(self, "visibility/opacity", 0, 1, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	
	var inner_circle = get_node("Main/InnerCircle")
	get_node("Tween 2").interpolate_property(inner_circle, "transform/scale", Vector2(0.7, 0.7), Vector2(1, 1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	var outer_circle = get_node("Main/OuterCircle")
	get_node("Tween 2").interpolate_property(outer_circle, "transform/scale", Vector2(1.2, 1.2), Vector2(1, 1), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	var phase_header = get_node("Main/PhaseHeader")
	get_node("Tween 2").interpolate_property(phase_header, "rect/pos", start_pos, end_pos, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	
	get_node("Tween").start()
	get_node("Tween 2").start()
	
	yield(get_node("Tween"), "tween_complete")
	
	if enemy_phase:
		get_node("Timer").set_wait_time(0.6)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
	else:
		get_node("Main/Flash").set_opacity(0)
		
		var flash = get_node("Main/Flash")
		var start_pos = Vector2(-100, 0)
		var end_pos = Vector2(100, 0)
		get_node("Tween").interpolate_property(flash, "transform/pos", start_pos, Vector2(0, 0), 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
		get_node("Tween").interpolate_property(flash, "visibility/opacity", 0, 1, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		get_node("Tween").start()
		yield(get_node("Tween"), "tween_complete")
		yield(get_node("Tween"), "tween_complete")
	
		get_node("Main/Turn").set_text(str(current_turn + 1) + "/" + str(turn_limit))
	
		get_node("Tween").interpolate_property(flash, "transform/pos", Vector2(0, 0), end_pos, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN)
		get_node("Tween").interpolate_property(flash, "visibility/opacity", 1, 0, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		yield(get_node("Tween"), "tween_complete")
		yield(get_node("Tween"), "tween_complete")
		
		get_node("Timer").set_wait_time(0.9)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")
		
	
	get_node("Tween 2").interpolate_property(inner_circle, "transform/scale", Vector2(1, 1), Vector2(0.7, 0.7), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(outer_circle, "transform/scale", Vector2(1, 1), Vector2(1.2, 1.2), 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	get_node("Tween 2").interpolate_property(phase_header, "rect/pos", end_pos, start_pos, 0.2, Tween.TRANS_QUAD, Tween.EASE_IN)
	
	get_node("Tween").start()
	get_node("Tween 2").start()
	
	var is_start = current_turn == 0 and self.has_previous_score
	var is_final_turn = !enemy_phase and current_turn + 1 == turn_limit
	
	if is_start or is_final_turn:
		get_node("Tween").interpolate_property(get_node("Main"), "visibility/opacity", 1, 0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
		get_node("Tween").start()
		yield(get_node("Tween"), "tween_complete")
		
		if is_start:
			get_node("Tween").interpolate_property(get_node("TurnSubtext"), "visibility/opacity", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
			get_node("Tween").interpolate_property(get_node("TurnSubtext"), "visibility/opacity", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 2)
		elif is_final_turn:
			get_node("Tween").interpolate_property(get_node("FinalPhaseHeader")
			, "visibility/opacity", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
			get_node("Tween").interpolate_property(get_node("FinalPhaseHeader")
			, "visibility/opacity", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.2)
			get_node("AnimationPlayer").play("FinalPhaseFlash")
	
		get_node("Tween").start()

		yield(get_node("Tween"), "tween_complete")
		yield(get_node("Tween"), "tween_complete")

	get_node("Tween").interpolate_property(self, "visibility/opacity", 1, 0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	get_node("Tween").start()
	get_parent().blur_lighten(0.2)
	yield(get_node("Tween"), "tween_complete")
	
	#reset needed for the final enemy phase after final player phase
	get_node("Main").set_opacity(1)
	get_node("AnimationPlayer").play("Spin")
	
	if enemy_phase:
		get_node("Timer").set_wait_time(0.2)
		get_node("Timer").start()
		yield(get_node("Timer"), "timeout")

	emit_signal("animation_done")
	

func set_phase(current_turn, enemy_phase):
	if enemy_phase:
		get_node("SamplePlayer").play("enemy_phase")
		get_node("Main/PhaseHeader").set_text("ENEMY PHASE")
		get_node("Main/Hexagon").play("enemy_phase")
		get_node("Main/InnerCircle").play("enemy_phase")
		get_node("Main/OuterCircle").play("enemy_phase")
	else:
		get_node("SamplePlayer").play("player_phase")
		if current_turn == 0:
			get_node("Main/PhaseHeader").set_text(str(self.name.to_upper()))
		else:
			get_node("Main/PhaseHeader").set_text("PLAYER PHASE")
		get_node("Main/Hexagon").play("player_phase")
		get_node("Main/InnerCircle").play("player_phase")
		get_node("Main/OuterCircle").play("player_phase")


	#then when the turn updates, we want the flash to shoot across the screen over the text
