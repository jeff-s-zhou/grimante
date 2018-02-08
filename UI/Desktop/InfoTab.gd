extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var id
var skill_description
signal active

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("TextureButton").connect("mouse_enter", self, "set_active")


func initialize(id, skill_description):
	self.id = id
	self.skill_description = skill_description
	get_node("Label").set_text(self.skill_description.type.to_upper())
	
	
func set_active():
	get_node("TextureButton").hide()
	get_node("Label").set_opacity(1.0)
	emit_signal("active", self.id, self.skill_description)
	
	
func set_inactive():
	get_node("Label").set_opacity(0.5)
	get_node("TextureButton").show()
	