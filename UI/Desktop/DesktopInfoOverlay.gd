extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var description_sequence

signal description_finished


var indirect_body_header_text = "[color=#ffd824][b]%s[/b] [i]%s Ability[/i][/color]"
var direct_body_header_text = "[color=#ff5151][b]%s[/b] [i]%s Ability[/i][/color]"
var passive_body_header_text = "[color=#995ffc][b]%s[/b] [i]%s Ability[/i][/color]"

var resolution 
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _enter_tree():
	self.resolution = get_node("/root/global").get_resolution()

func close():
	get_node("InfoTabs").clear()
	set_process_input(false)
	emit_signal("description_finished")
	hide()


func _input(event):
#	if get_node("/root/InputHandler").is_ui_cycle(event):
#		if self.count < self.description_sequence.size():
#			display_description()
#		else:
#			self.count = 0
#			display_description()
#				set_process_input(false)
#				emit_signal("description_finished")
#				hide()
			
	if get_node("/root/InputHandler").is_select(event) \
	or get_node("/root/InputHandler").is_deselect(event) \
	or get_node("/root/InputHandler").is_description(event):
		close()

func display_description():
	var description = self.description_sequence[0]
	
	if typeof(description) == TYPE_DICTIONARY: #for Heroes
		get_node("InfoTabs").show()
		get_node("InfoTabs").initialize(self.description_sequence)
	else:
		get_node("EnemyInfo/Body").set_bbcode(description)


func display_enemy_info(hovered_piece):
	set_process_input(true)
	get_node("HeroInfoSubOverlay").hide()
	var pos = hovered_piece.get_global_pos()
	var title = hovered_piece.unit_name
	var text = hovered_piece.hover_description
	var modifier_descriptions = hovered_piece.modifier_descriptions
	
	print("modifier_descriptions:", modifier_descriptions)

	get_node("Overlay").set_global_pos(pos)
	
	if pos.x > get_viewport_rect().size.width/2:
		get_node("Header").set_pos(Vector2(40, 40))
		get_node("EnemyInfo").set_pos(Vector2(38, 150))
		get_node("ContinueLabel").set_pos(Vector2(62, 560))
	else:
		var x = (get_viewport_rect().size.width/2) + 20
		get_node("Header").set_pos(Vector2(x, 40))
		get_node("EnemyInfo").set_pos(Vector2(x - 2, 150))
		get_node("ContinueLabel").set_pos(Vector2(x + 22, 560))
	get_node("EnemyInfo").show()
	
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
	get_node("EnemyInfo").hide()
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
		x = 38
	else:
		x = (get_viewport_rect().size.width/2) + 18
		
	get_node("Header").set_pos(Vector2(x, 40))
	get_node("Header").set_text(title.to_upper())
	if get_node("HeroInfoSubOverlay").is_displaying_icons():
		print("is displaying icons")
		get_node("HeroInfoSubOverlay").set_pos(Vector2(x, 114))
		get_node("InfoTabs").set_pos(Vector2(x, 160))
	else:
		print("not displaying icons")
		get_node("InfoTabs").set_pos(Vector2(x, 130))
	get_node("ContinueLabel").set_pos(Vector2(x + 18, 600))
	
	display_description()
	show()