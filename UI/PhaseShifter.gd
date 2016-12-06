
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("PhaseSlider").set_z(2)
	get_node("PhaseSlider 2").set_z(2)
	get_node("Text").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height/2))
	get_node("Text").set_z(3)


func player_phase_animation():
	get_node("PhaseSlider").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height/2 + 50))
	get_node("PhaseSlider/AnimatedSprite").play("blue")
	get_node("PhaseSlider/AnimationPlayer").play("slide_right")
	
	get_node("PhaseSlider 2").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height/2 - 50))
	get_node("PhaseSlider 2/AnimatedSprite").play("blue")
	get_node("PhaseSlider 2/AnimationPlayer").play("slide_left")
	
	get_node("Text").play("player_phase")
	
	get_node("AnimationPlayer").play("blur")

	
func enemy_phase_animation():
	get_node("PhaseSlider").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height/2 + 50))
	get_node("PhaseSlider/AnimatedSprite").play("red")
	get_node("PhaseSlider/AnimationPlayer").play("slide_right")
	
	get_node("PhaseSlider 2").set_pos(Vector2(get_viewport_rect().size.width/2, get_viewport_rect().size.height/2 - 50))
	get_node("PhaseSlider 2/AnimatedSprite").play("red")
	get_node("PhaseSlider 2/AnimationPlayer").play("slide_left")
	
	get_node("Text").play("enemy_phase")
	
	get_node("AnimationPlayer").play("blur")