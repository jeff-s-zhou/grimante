extends Node

var queue = []
var mid_processing = false

var stopped_flag = false

var processing_queue = []

var lock = Mutex.new()

var count_lock = Mutex.new()

var waiting_count_lock = Mutex.new()

var waiting_count = 0

var animation_count = 0

signal animation_count_update(count)

signal animations_finished

func _ready():
	set_process(true)

func enqueue(node, func_ref, blocking, args=[]):
	#print("enqueuing: " + func_ref)
	if !stopped_flag:
		self.lock.lock()
		self.queue.append({"node":node, "func_ref":func_ref, "blocking":blocking, "args":args})
		self.lock.unlock()
		
func is_busy():
	return self.queue != [] or self.mid_processing

func is_animating():
	print("calling is_animating")
	print(self.queue != [] or self.mid_processing or get_animation_count() > 0 or get_waiting_count() > 0)
	return self.queue != [] or self.mid_processing or get_animation_count() > 0 or get_waiting_count() > 0
	#return get_animation_count() > 0
	
func debug():
	print(str(get_animation_count()) + " is the animation_count")
	print(self.queue)
	print(self.mid_processing)
	
func set_stopped(flag):
	self.stopped_flag = flag
	
func get_animation_count():
	self.count_lock.lock()
	var count = self.animation_count
	self.count_lock.unlock()
	return count
	
func reset():
	self.count_lock.lock()
	self.animation_count = 0
	self.count_lock.unlock()
	set_stopped(false)
	
func update_animation_count(amount):
	self.count_lock.lock()
	self.animation_count += amount
#	print("animation_count: " + str(self.animation_count))
	emit_signal("animation_count_update", self.animation_count)
	if self.animation_count == 0:
		emit_signal("animations_finished")
	self.count_lock.unlock()

func get_waiting_count():
	self.waiting_count_lock.lock()
	var count = self.waiting_count
	self.waiting_count_lock.unlock()
	return count
	
func update_waiting_count(amount):
	self.waiting_count_lock.lock()
	self.waiting_count += amount
	self.waiting_count_lock.unlock()

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
#		print("animating " + str(node.get_name()))
#		print("animating " + str(func_ref) + ", blocking: " + str(blocking))
		if args == []:
			node.call(func_ref)
			#GIVE ME FUCKING SPREAD SYNTAX AAAAAAAAAGGGGGGGGHHHHHHHH
		elif args.size() == 1:
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

	self.mid_processing = false
	if self.queue == [] and !self.mid_processing and get_animation_count() == 0:
		emit_signal("animations_finished")
#	if self.queue == [] and self.processing_queue == []:
#		emit_signal("animations_finished")

	
#	if self.queue == [] and self.processing_queue == []:
#		yield(node, "strict_animation_done")
#		emit_signal("animations_finished")