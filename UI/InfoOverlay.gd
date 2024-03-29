extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var description_sequence

signal description_finished

#var continue_text = "\n[color=#29e4ad][i]Click anywhere to continue [%s/%s][/i][/color]"
var continue_text = "Click anywhere to continue [%s/%s]"
var count = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _input(event):
	if get_node("InputHandler").is_select(event):
		if self.count < self.description_sequence.size():
			display_description()
		else:
			self.count = 0
			display_description()
#			set_process_input(false)
#			emit_signal("description_finished")
#			hide()
			
	elif get_node("InputHandler").is_deselect(event):
		self.count = 0
		set_process_input(false)
		emit_signal("description_finished")
		hide()

func display_description():
	var filled_continue_text = continue_text % [str(self.count + 1), str(self.description_sequence.size())]
	get_node("Body").set_bbcode(self.description_sequence[self.count])
	get_node("ContinueLabel").set_text(filled_continue_text)
	self.count += 1


func display_enemy_info(hovered_piece):
	set_process_input(true)
	get_node("HeroInfoSubOverlay").hide()
	var pos = hovered_piece.get_global_pos()
	var title = hovered_piece.unit_name
	var text = hovered_piece.hover_description
	var modifier_descriptions = hovered_piece.modifier_descriptions
	
	print("modifier_descriptions:", modifier_descriptions)
	
	get_node("Overlay").set_global_pos(pos)
	
	if pos.y > get_viewport_rect().size.height/2:
		get_node("Header").set_pos(Vector2(70, 150))
		get_node("Body").set_pos(Vector2(70, 230))
		get_node("ContinueLabel").set_pos(Vector2(70, 480))
	else:
		get_node("Header").set_pos(Vector2(70, get_viewport_rect().size.height  - 500))
		get_node("Body").set_pos(Vector2(70, get_viewport_rect().size.height  - 420))
		get_node("ContinueLabel").set_pos(Vector2(70, get_viewport_rect().size.height - 170))
	
	get_node("Header").set_text(title.to_upper())
	if modifier_descriptions.keys() != []:
		for key in modifier_descriptions.keys():
			var modifier_description = "\n\n" + key + ": " + modifier_descriptions[key]
			print(modifier_description)
			print(text)
			text += modifier_description
	
	self.description_sequence = [text]
	
	display_description()
	show()
	
func display_player_info(hovered_piece):
	set_process_input(true)
	var shielded = hovered_piece.DEFAULT_SHIELD
	var movement = hovered_piece.DEFAULT_MOVEMENT_VALUE
	var inspire_type = hovered_piece.assist_type
	
	get_node("HeroInfoSubOverlay").display_info(shielded, movement, inspire_type)
	
	var title = hovered_piece.unit_name
	var attack_description = hovered_piece.direct_attack_description
	var indirect_attack_description = hovered_piece.indirect_attack_description
	var passive_description = hovered_piece.passive_description
	self.description_sequence = attack_description + indirect_attack_description + passive_description
	var pos = hovered_piece.get_global_pos()
	
	get_node("Overlay").set_global_pos(pos)
	
	if pos.y > get_viewport_rect().size.height/2:
		get_node("Header").set_pos(Vector2(70, 150))
		get_node("HeroInfoSubOverlay").set_pos(Vector2(70, 210))
		get_node("Body").set_pos(Vector2(70, 270))
		get_node("ContinueLabel").set_pos(Vector2(70, 480))
	else:
		get_node("Header").set_pos(Vector2(70, get_viewport_rect().size.height  - 500))
		get_node("HeroInfoSubOverlay").set_pos(Vector2(70, get_viewport_rect().size.height  - 440))
		get_node("Body").set_pos(Vector2(70, get_viewport_rect().size.height  - 380))
		get_node("ContinueLabel").set_pos(Vector2(70, get_viewport_rect().size.height - 170))
		
	get_node("Header").set_text(title.to_upper())
	display_description()
	show()