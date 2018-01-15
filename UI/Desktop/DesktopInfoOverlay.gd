extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var description_sequence

signal description_finished


var indirect_body_header_text = "[color=#ffd824][b]%s[/b] [i]%s[/i][/color]"
var direct_body_header_text = "[color=#ff5151][b]%s[/b] [i]%s Ability[/i][/color]"
var continue_text = "CLICK TO CYCLE TEXT (%s/%s)"
var count = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _enter_tree():
	var resolution = get_node("/root/global").get_resolution()
	get_node("ExitButton").set_global_pos(Vector2(resolution.x - 34
	, 10))
	get_node("ExitButton").connect("pressed", self, "close")


func close():
	set_process_input(false)
	self.count = 0
	emit_signal("description_finished")
	hide()


func _input(event):
	if get_node("/root/InputHandler").is_ui_cycle(event):
		if self.count < self.description_sequence.size():
			display_description()
		else:
			self.count = 0
			display_description()
#				set_process_input(false)
#				emit_signal("description_finished")
#				hide()
			
	elif get_node("/root/InputHandler").is_deselect(event) or get_node("/root/InputHandler").is_description(event):
		close()

func display_description():
	var filled_continue_text = continue_text % [str(self.count + 1), str(self.description_sequence.size())]
	var description = self.description_sequence[self.count]
	
	if typeof(description) == TYPE_DICTIONARY: #for Heroes
		var name = description["name"]
		var type = description["type"]
		var text = description["text"]
		if type.to_lower() == "indirect":
			get_node("BodyHeader").set_bbcode(self.indirect_body_header_text % [name, type])
		else:
			get_node("BodyHeader").set_bbcode(self.direct_body_header_text % [name, type])
		get_node("Body").set_bbcode(text)
	else:
		get_node("Body").set_bbcode(description)
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
	
	get_node("BodyHeader").set_bbcode("")
	get_node("Overlay").set_global_pos(pos)
	
	if pos.x > get_viewport_rect().size.width/2:
		get_node("Header").set_pos(Vector2(40, 40))
		get_node("Body").set_pos(Vector2(40, 150))
		get_node("ContinueLabel").set_pos(Vector2(40, 430))
	else:
		var x = (get_viewport_rect().size.width/2) + 20
		get_node("Header").set_pos(Vector2(x, 40))
		get_node("Body").set_pos(Vector2(x, 150))
		get_node("ContinueLabel").set_pos(Vector2(x, 430))
	
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
	var inspire_type = hovered_piece.assist_type
	print("shielded is: ", shielded)
	get_node("HeroInfoSubOverlay").display_info(shielded, inspire_type)
	
	var title = hovered_piece.unit_name
	self.description_sequence = hovered_piece.descriptions
	var pos = hovered_piece.get_global_pos()
	
	get_node("Overlay").set_global_pos(pos)
	var x
	if pos.x > get_viewport_rect().size.width/2:
		x = 40
	else:
		x = (get_viewport_rect().size.width/2) + 20
		
	get_node("Header").set_pos(Vector2(x, 40))
	get_node("Header").set_text(title.to_upper())
	if get_node("HeroInfoSubOverlay").is_displaying_icons():
		print("is displaying icons")
		get_node("HeroInfoSubOverlay").set_pos(Vector2(x, 114))
		get_node("BodyHeader").set_pos(Vector2(x, 160))
		get_node("Body").set_pos(Vector2(x, 198))
	else:
		print("not displaying icons")
		get_node("BodyHeader").set_pos(Vector2(x, 130))
		get_node("Body").set_pos(Vector2(x, 165))
	get_node("ContinueLabel").set_pos(Vector2(x, 483))
	
	display_description()
	show()