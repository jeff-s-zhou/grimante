extends Node

var queue = []
var mid_processing = false

var processing_queue = []

var lock = Mutex.new()

func _ready():
	set_process(true)
	print(lock)

func enqueue(node, func_ref, arguments=[]):
	self.lock.try_lock()
	self.queue.append([node, func_ref, arguments])
	self.lock.unlock()

func _process(delta):
	while self.queue != [] and !self.mid_processing:
		print("met this conditional")
		self.lock.try_lock()
		self.processing_queue = self.queue
		self.queue = null
		self.lock.unlock()
		process_animations()

		
func process_animations():
	self.mid_processing = true
	while self.processing_queue != []:
		var animation_call = self.processing_queue[0]
		self.processing_queue.pop_front()
		var node = animation_call[0]
		var func_ref = animation_call[1]
		var args = animation_call[2]
		node.call(func_ref, args)
		yield(node, "animation_done")
	self.mid_processing = false