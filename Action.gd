extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var affected_range
var inflicts_damage #if disabled, won't trigger assassin's passive. probs only used by the assassin's passive lol
var assassin_passive
var func_calls = []
var caller = null
#onready var grid = get_node("/root/Combat/Grid")

func _init(caller, inflicts_damage=true, assassin_passive=false).():
	self.caller = caller
	self.inflicts_damage = inflicts_damage
	self.assassin_passive = assassin_passive

func add_call(func_ref, args, affected_range):
	if typeof(affected_range) == TYPE_VECTOR2:
		affected_range = [affected_range]
	func_calls.append({"func_ref":func_ref, "args":args, "affected_range":affected_range})
	
func frozen_first_sort(first, second):
	return !first.frozen and second.frozen
	
func execute():
	var death_flag = false
	
	var affected_pieces = {}
		
	for func_call in func_calls:
		var func_ref = func_call.func_ref
		var args = func_call.args
		var affected_range = func_call.affected_range
		var pieces = []
		
		for coords in affected_range:
			if get_node("/root/Combat/Grid").pieces.has(coords):
				var piece = get_node("/root/Combat/Grid").pieces[coords]
				pieces.append(piece)
				
				#keep a set of pieces that had something done to them
				if !affected_pieces.has(piece):
					affected_pieces[piece] = true
		pieces.sort_custom(self, "frozen_first_sort") #this way frozen will usually resolve before seraphs
		for piece in pieces:
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
				
	for piece in affected_pieces.keys():
		if piece.has_method("deathrattle"):
			piece.deathrattle()
		
		if piece.side == "ENEMY" and piece.hp == 0:
			death_flag = true
	
	if inflicts_damage:
		if !assassin_passive: #assassin passive can't trigger itself
			var assassin_passive_range = []
			for piece in affected_pieces.keys():
				#if the piece is still alive after all deathrattles are resolved, let it trigger assassin's passive
				if piece.side == "ENEMY" and piece.hp != 0:
					assassin_passive_range.append(piece.coords)
	
			get_node("/root/Combat/Grid").handle_assassin_passive(assassin_passive_range, self.caller)
		
		var lightning_range = []
		for piece in affected_pieces.keys():
			#if the piece is still alive after all deathrattles are resolved, let it trigger assassin's passive
			if piece.side == "ENEMY" and piece.hp != 0:
				lightning_range.append(piece.coords)
		get_node("/root/Combat/Grid").handle_lightning(lightning_range, self.caller)
	
	#the assassin's passive can't trigger Inspire
	if death_flag and self.caller.has_method("trigger_assist_flag") and inflicts_damage and !assassin_passive:
		self.caller.trigger_assist_flag()
		
	queue_free()