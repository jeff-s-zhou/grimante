extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var charge = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_charge(0)
	hide()

func set_charge(charge):
	self.charge = charge
	
	if charge == 0:
		hide()
	
	elif charge == 1:
		show()
		get_node("Charge1").show()
		get_node("Charge2").hide()
		get_node("Charge3").hide()
		
	elif charge == 2:
		show()
		get_node("Charge1").show()
		get_node("Charge2").show()
		get_node("Charge3").hide()
		
	elif charge == 3:
		show()
		get_node("Charge1").show()
		get_node("Charge2").show()
		get_node("Charge3").show()
	