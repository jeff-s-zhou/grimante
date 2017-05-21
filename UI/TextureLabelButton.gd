extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal pressed
signal button_down
signal button_up

var normal_height = get_node("TextureButton").get_normal_texture().get_height()
var pressed_height = get_node("TextureButton").get_pressed_texture().get_height()



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect(get_node("TextureButton"), "pressed", "pressed")
	connect(get_node("TextureButton"), "button_down", "button_down")
	connect(get_node("TextureButton"), "button_up", "button_up")
	
	#connect all the signals from the button inside this
	#have all the labels and sprites grouped inside a node2d called "Toppings"
	#have them move downward the difference in y height of the default texture and the pressed texture
	
func pressed():
	emit_signal("pressed")
	
	
func button_down():
	emit_signal("button_down")
	get_node("Toppings").translate(Vector2(0, self.normal_height - self.pressed_height))
	
func button_up():
	emit_signal("button_up")
	get_node("Toppings").translate(Vector2(0, self.pressed_height - self.normal_height))
	
