extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var grid = null


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#message {enemy, damage, effects}

func add_to_queue(message):
	if typeof(message) == TYPE_ARRAY:
		for sub_message in message:
			sub_message["enemy"].handle_pre_damage(damage)
			#resolve pre-damage phase for all submessages
			pass
		for sub_message in message:
			susb_message["enemy"].handle_damage(damage)
			pass
		for sub_message in message:
			sub_message["enemy"].handle_post_damage(damage)
			#resolve post_damage phase for all submessages
			pass
		for sub_message in message:
			sub_message["enemy"].resolve_death()
			#resolve possible death for all submessages
			pass
	else: #typeof(message) == TYPE_DICTIONARY
		#resolve pre-damage phase
		#resolve damage phase
		#resolve post_damage phase
		#resolve possible death
		pass
	
