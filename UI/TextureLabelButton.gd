extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal pressed
signal released
signal button_down
signal button_up

onready var normal_height = get_node("TextureButton").get_normal_texture().get_height()
onready var pressed_height = get_node("TextureButton").get_pressed_texture().get_height()

var y_difference = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("TextureButton").connect("pressed", self, "is_pressed")
	get_node("TextureButton").connect("button_down", self, "is_button_down")
	get_node("TextureButton").connect("button_up", self, "is_button_up")
	
	
	#connect all the signals from the button inside this
	#have all the labels and sprites grouped inside a node2d called "Toppings"
	#have them move downward the difference in y height of the default texture and the pressed texture
	
func is_pressed():
	emit_signal("pressed")
	
func is_button_down():
	emit_signal("button_down")
	get_node("Toppings").translate(Vector2(0, self.y_difference))
	
func is_button_up():
	emit_signal("button_up")
	get_node("Toppings").translate(Vector2(0, -1 * self.y_difference))
	
