extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var line_info
var line_distance
var full_length
var unit
var offset_length = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	draw_dotted(Vector2(0, 0), Vector2(300, 300))
	set_process(true)
	
func show():
	set_process(true)
	.show()

func hide():
	set_process(false)
	.hide()
	
func draw_dotted(start, end):
	self.line_info = {"start":start, "end":end}
	self.line_distance = self.line_info.end - self.line_info.start
	self.full_length = line_distance.length()
	self.unit = line_distance.normalized() * 15
	update()
	
func _process(delta):
	self.offset_length += 4 * delta
	if (self.unit * self.offset_length).length() > self.unit.length() * 2:
		self.offset_length = 0
	else:
		#this needs to be in the else block or else it breaks the drawing
		update()

#no comments, because life is suffering -Jeff
func _draw():
	if self.line_info != null:
		var distance_travelled = (unit * self.offset_length).length()
		var count = 0
		var start = self.line_info.start + (unit * self.offset_length)
		
		if self.offset_length > 0:
			if (self.unit * self.offset_length).length() > self.unit.length():
				var offset = (self.unit * self.offset_length) - self.unit
				draw_line(self.line_info.start + offset, start)
			else:
				draw_line(self.line_info.start, start)
			count = 1
		
		while distance_travelled < full_length:
			if count % 2 == 0:
				var end = start + unit
				if distance_travelled + unit.length() > full_length:
					end = self.line_info.end
				draw_line(start, end)
			start = start + unit
			distance_travelled += unit.length()
			count += 1
			
func draw_line(start, end):
	.draw_line(start, end, Color(37, 247, 255, 0.3), 4)
	.draw_line(start, end, Color(255, 255, 255, 0.7), 3)
	
		
#	
