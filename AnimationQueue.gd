extends Node

var queue = []
var mid_processing = false

var processing_queue = []

var lock = Mutex.new()

signal animations_finished

func _ready():
	set_process(true)

func enqueue(node, func_ref, blocking, args=[]):
	print("enqueuing: " + func_ref)
	self.lock.lock()
	self.queue.append({"node":node, "func_ref":func_ref, "blocking":blocking, "args":args})
	self.lock.unlock()
	
func is_busy():
	return self.queue != [] or self.mid_processing


func _process(delta):
	while self.queue != [] and !self.mid_processing:
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
		var blocking = animation_action["blocking"]
		var func_ref = animation_action["func_ref"]
		var args = animation_action["args"]
		if node.has_method("set_mid_animation"):
			node.set_mid_animation(true)
		if args == []:
			node.call(func_ref)
		else:
			#GIVE ME FUCKING SPREAD SYNTAX AAAAAAAAAGGGGGGGGHHHHHHHH
			if args.size() == 1:
				node.call(func_ref, args[0])
			elif args.size() == 2:
				node.call(func_ref, args[0], args[1])
			elif args.size() == 3:
				node.call(func_ref, args[0], args[1], args[2])
			elif args.size() == 4:
				node.call(func_ref, args[0], args[1], args[2], args[3])
			elif args.size() == 5:
				node.call(func_ref, args[0], args[1], args[2], args[3], args[4])
			elif args.size() == 6:
				node.call(func_ref, args[0], args[1], args[2], args[3], args[4], args[5])
			elif args.size() == 7:
				node.call(func_ref, args[0], args[1], args[2], args[3], args[4], args[5], args[6])
			else:
				print("Error: EXCEEDED MAX NUMBER OF ARGUMENTS IN AnimationQueue")
		if blocking:
			yield(node, "animation_done")
		if node.has_method("set_mid_animation"):
			node.set_mid_animation(false)
	self.mid_processing = false
	
	if self.queue == [] and self.processing_queue == []:
		emit_signal("animations_finished")

	
#	if self.queue == [] and self.processing_queue == []:
#		yield(node, "strict_animation_done")
#		emit_signal("animations_finished")