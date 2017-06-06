extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var description_sequence

signal description_finished

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _input(event):
	if get_node("InputHandler").is_select(event):
		if self.description_sequence.size() > 0:
			display_description()
		else:
			set_process_input(false)
			emit_signal("description_finished")
			hide()
	
func display_description():
	get_node("Body").set_bbcode(self.description_sequence[0])
	self.description_sequence.pop_front()


func display_enemy_info(hovered_piece):
	set_process_input(true)
	get_node("HeroInfoSubOverlay").hide()
	var pos = hovered_piece.get_global_pos()
	var title = hovered_piece.unit_name
	var text = hovered_piece.hover_description
	var modifier_descriptions = hovered_piece.modifier_descriptions
	
	
	get_node("Overlay").set_global_pos(pos)
	
	if pos.y > get_viewport_rect().size.height/2:
		get_node("Header").set_pos(Vector2(70, 150))
		get_node("Body").set_pos(Vector2(70, 230))
	else:
		get_node("Header").set_pos(Vector2(70, get_viewport_rect().size.height  - 500))
		get_node("Body").set_pos(Vector2(70, get_viewport_rect().size.height  - 420))
	
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
	var armor = hovered_piece.DEFAULT_ARMOR_VALUE
	var movement = hovered_piece.DEFAULT_MOVEMENT_VALUE
	var inspire_type = hovered_piece.assist_type
	
	get_node("HeroInfoSubOverlay").display_info(armor, movement, inspire_type)
	
	var title = hovered_piece.unit_name
	var attack_description = hovered_piece.attack_description
	var passive_description = hovered_piece.passive_description
	self.description_sequence = attack_description + passive_description
	var pos = hovered_piece.get_global_pos()
	
	get_node("Overlay").set_global_pos(pos)
	
	if pos.y > get_viewport_rect().size.height/2:
		get_node("Header").set_pos(Vector2(70, 150))
		get_node("HeroInfoSubOverlay").set_pos(Vector2(70, 210))
		get_node("Body").set_pos(Vector2(70, 270))
	else:
		get_node("Header").set_pos(Vector2(70, get_viewport_rect().size.height  - 500))
		get_node("HeroInfoSubOverlay").set_pos(Vector2(70, get_viewport_rect().size.height  - 440))
		get_node("Body").set_pos(Vector2(70, get_viewport_rect().size.height  - 380))
		
	get_node("Header").set_text(title.to_upper())
	display_description()
	show()