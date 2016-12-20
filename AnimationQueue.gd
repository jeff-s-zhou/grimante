extends Node

var queue = []
var mid_processing = false

var processing_queue = []

var lock = Mutex.new()

func _ready():
	set_process(true)
	print(lock)

func enqueue(node, func_ref, does_yield, args=[]):
	self.lock.try_lock()
	self.queue.append({"node":node, "func_ref":func_ref, "does_yield":does_yield, "args":args})
	self.lock.unlock()


func _process(delta):
	while self.queue != [] and !self.mid_processing:
		print("met this conditional")
		self.lock.try_lock()
		self.processing_queue = self.queue
		self.queue = []
		self.lock.unlock()
		process_animations()

		
func process_animations():
	self.mid_processing = true
	while self.processing_queue != []:
		var animation_action = self.processing_queue[0]
		self.processing_queue.pop_front()
		var node = animation_action["node"]
		var does_yield = animation_action["does_yield"]
		var func_ref = animation_action["func_ref"]
		var args = animation_action["args"]
		if args == []:
			node.call(func_ref)
		else:
			node.call(func_ref, args)
		if does_yield:
			yield(node, "animation_done")
	self.mid_processing = false