extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var func_calls = []

var blocking = false

signal animation_done

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _init(blocking=false):
	self.blocking = blocking
	
func is_empty():
	return self.func_calls == []

func add(node, func_ref, blocking, args=[]):
	#print("adding " + func_ref)
	var func_call = {"node":node, "func_ref":func_ref, "blocking":blocking, "args":args}
	func_calls.append(func_call)


func execute():
	for func_call in func_calls:
		var node = func_call.node
		var func_ref = func_call.func_ref
		var blocking = func_call.blocking
		var args = func_call.args

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

	emit_signal("animation_done")

	free() #call this instead of queue_free() because queue_free requires us to add it to the tree