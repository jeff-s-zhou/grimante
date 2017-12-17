extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func animate(pos):
	set_pos(Vector2(self.get_pos().x, pos.y))
	set_emit_timeout(4)
	set_emitting(true)
	