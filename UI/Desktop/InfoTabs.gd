extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const TabPrototype = preload("res://UI/Desktop/InfoTab.tscn")

var tabs = []
var active_tab_id
var active_position = Vector2(130, 0)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize(descriptions):
	for description in descriptions:
		var tab = TabPrototype.instance()
		add_child(tab)
		tab.connect("active", self, "set_active_tab")
		var id = self.tabs.size()
		tab.initialize(id, description)
		tab.set_pos(active_position * id + Vector2(65, 18))
		tabs.append(tab)
	self.tabs[0].set_active()
	
	
func clear():
	hide()
	for tab in self.tabs:
		tab.queue_free()
	self.tabs = []
	self.active_tab_id = null
	

func set_active_tab(active_tab_id, skill):
	for tab in self.tabs:
		if tab.id != active_tab_id:
			tab.set_inactive()
	self.active_tab_id = active_tab_id
	get_node("ActiveTabSprite").play(str(active_tab_id + 1))
	var skill_name = skill["name"]
	var skill_description = skill["text"]
	get_node("SkillName").set_text(skill_name)
	get_node("SkillDescription").set_bbcode(skill_description)