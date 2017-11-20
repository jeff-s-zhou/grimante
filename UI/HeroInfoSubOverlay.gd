extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var ASSIST_TYPES = get_node("/root/AssistSystem").ASSIST_TYPES

var pos_index = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func display_info(shielded, inspire_type):
	reset_positions()
	
	if shielded:
		get_node("ArmorIcon").show()
		get_node("ArmorIcon").set_pos(get_icon_pos())
	else:
		get_node("ArmorIcon").hide()
		
	if get_node("/root/AssistSystem").is_assist_enabled():
		if inspire_type == ASSIST_TYPES.attack:
			get_node("InspireIcon").play("attack")
			get_node("InspireIcon/Label").set_text("Inspire Attack")
		elif inspire_type == ASSIST_TYPES.movement:
			get_node("InspireIcon").play("movement")
			get_node("InspireIcon/Label").set_text("Inspire Movement")
		elif inspire_type == ASSIST_TYPES.defense:
			get_node("InspireIcon").play("defense")
			get_node("InspireIcon/Label").set_text("Inspire Shield")
		
		get_node("InspireIcon").set_pos(get_icon_pos())
	else:
		get_node("InspireIcon").hide()
	show()
	
func reset_positions():
	self.pos_index = 0
	
func get_icon_pos():
	if self.pos_index == 0:
		self.pos_index += 1
		return Vector2(15, 14)
	else:
		return Vector2(170, 14)
		
func is_displaying_icons():
	return self.pos_index > 0