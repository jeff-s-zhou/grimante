extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#do we make these seperate for aoe calls? 
#why not just call the death check afterwards each time

class AOEAction:
	var affected_range
	var func_calls = []
	func _init(affected_range):
		self.affected_range = affected_range
	
	func add_call(func_ref, args):
		func_calls.append({"func_ref":func_ref, "args":args})
		
	func execute():
		for coords in affected_range:
			var piece = grid.pieces[coords]
			for func_call in func_calls:
				var func_ref = func_call.func_ref
				var args = func_call.args
				if args == []:
					piece.call(func_ref)
					#GIVE ME FUCKING SPREAD SYNTAX AAAAAAAAAGGGGGGGGHHHHHHHH
				elif args.size() == 1:
					piece.call(func_ref, args[0])
				elif args.size() == 2:
					piece.call(func_ref, args[0], args[1])
				elif args.size() == 3:
					piece.call(func_ref, args[0], args[1], args[2])
				elif args.size() == 4:
					piece.call(func_ref, args[0], args[1], args[2], args[3])
				elif args.size() == 5:
					piece.call(func_ref, args[0], args[1], args[2], args[3], args[4])
				elif args.size() == 6:
					piece.call(func_ref, args[0], args[1], args[2], args[3], args[4], args[5])
				elif args.size() == 7:
					piece.call(func_ref, args[0], args[1], args[2], args[3], args[4], args[5], args[6])
				else:
					print("Error: EXCEEDED MAX NUMBER OF ARGUMENTS IN AnimationQueue")
					
		for coords in affected_range:
			grid.pieces[coords].aoe_death_check()