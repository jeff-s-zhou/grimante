extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal pressed
var level_set = null
var obtained_stars
var total_stars

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#hackiness needed since unique flag isn't working
	get_node("RegularButton").set_material(get_node("RegularButton").get_material().duplicate())
	get_node("GreyedButton").set_material(get_node("GreyedButton").get_material().duplicate())
	get_node("GoldenButton").connect("pressed", self, "is_pressed")
	get_node("RegularButton").connect("pressed", self, "is_pressed")

func set_disabled(flag):
	get_node("GreyedButton").set_disabled(flag)
	if flag:
		print("setting greyed")
		set_full_visibility(true, get_node("GreyedButton"))
		set_full_visibility(false, get_node("RegularButton"))
		get_node("GoldenButton").hide()
	else:
		if self.obtained_stars == self.total_stars: #completed
			print(str(self.obtained_stars) + "/" + str(self.total_stars))
			set_full_visibility(false, get_node("GreyedButton"))
			set_full_visibility(false, get_node("RegularButton"))
			get_node("GoldenButton").show()
		else:
			set_full_visibility(false, get_node("GreyedButton"))
			set_full_visibility(true, get_node("RegularButton"))
			get_node("GoldenButton").hide()

func initialize(level_set):
	self.level_set = level_set
	var stars = get_node("/root/State").get_stars(self.level_set)
	self.obtained_stars = stars[0]
	self.total_stars = stars[1]

#	var unlocked = get_node("/root/State").is_set_unlocked(level_set.id)
#	set_disabled(!unlocked)
	set_disabled(false)
	get_node("GreyedButton/Toppings/Label").set_text(str(self.level_set.id))
	get_node("RegularButton/Toppings/Label").set_text(str(self.level_set.id))
	get_node("GoldenButton/Toppings/Label").set_text(str(self.level_set.id))
	
	
	if self.obtained_stars > 0:
		var star_str = str(self.obtained_stars) + "/" + str(self.total_stars)
		get_node("RegularButton/Toppings/StarLabel").show()
		get_node("RegularButton/Toppings/StarLabel").set_text(star_str)
		get_node("GoldenButton/Toppings/StarLabel").show()
		get_node("GoldenButton/Toppings/StarLabel").set_text(star_str)
	
func is_pressed():
	emit_signal("pressed", self.level_set)
	
func defrost():
	set_full_visibility(true, get_node("GreyedButton"))
	set_full_visibility(false, get_node("RegularButton"))
	get_node("RegularButton").show()
	get_node("AnimationPlayer").play("defrost")
	
func goldify():
	pass
	
func set_full_visibility(flag, node):
	if flag:
		var material = node.get("material/material")
		print(get_name())
		print("before:", material.get("shader_param/strength"))
		material.set("shader_param/strength", 0)
		print("after:", material.get("shader_param/strength"))
		node.show()
	else:
		var material = node.get("material/material")
		material.set("shader_param/strength", 2)
		node.hide()