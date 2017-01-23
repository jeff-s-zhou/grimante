extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var grid = null


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#message {enemy, payload}
#payload {damage, effects}
#effects = heal, stun, freeze, poison, silence, (these are modifiers on damage) smash, non-lethal

func damage_payloader(damage, effects=null):
	var return_value = {"hp_change":damage * -1}
	if effects != null:
		return_value["effects"] = effects
	return return_value
	
func heal_payloader(heal):
	return {"hp_change":heal}
	

func handle_message(message):
	if typeof(message) == TYPE_ARRAY:
		for sub_message in message:
			#resolve pre-payload phase for all submessages
			sub_message["enemy"].handle_pre_payload(sub_message["payload"])
			
		for sub_message in message:
			sub_message["enemy"].handle_payload(sub_message["payload"])
			
		for sub_message in message:
			#resolve post_payload phase for all submessages
			sub_message["enemy"].handle_post_payload(sub_message["payload"])
			
		for sub_message in message:
			#resolve possible death for all submessages
			sub_message["enemy"].resolve_death()
			
	else: #typeof(message) == TYPE_DICTIONARY
		#resolve pre-payload phase
		#resolve payload phase
		#resolve post_payload phase
		#resolve possible death
		pass
	
