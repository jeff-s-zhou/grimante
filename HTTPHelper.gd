extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var URL = "104.236.237.104"

signal user_id_request_done(value)

signal attempt_session_id_request_done(value)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("LogRequest").connect("request_completed", self, "log_request_completed")
	get_node("UserIDRequest").connect("request_completed", self, "user_id_request_completed")
	get_node("AttemptSessionIDRequest").connect("request_completed", self, "attempt_session_id_request_completed")

	
func log_online(json_data):
	var headers=["User-Agent: Jeff", "Content-Type: application/json"]
	#get_node("LogRequest").request("http://127.0.0.1:5000/log", headers, false, HTTPClient.METHOD_POST, json_data)
	get_node("LogRequest").request("http://104.236.237.104/log", headers, false, HTTPClient.METHOD_POST, json_data)

func log_request_completed(result, response, headers, body):
	print("log request result: ", result)
	

func request_new_user_id(args):
	var headers=["User-Agent: Jeff", "Accept: */*"]
	get_node("UserIDRequest").request("http://104.236.237.104/get_new_user", headers)
	
func user_id_request_completed(result, response, headers, body):
	print("bytes got: ",body.size())
	var text = body.get_string_from_ascii()
	var id = int(text)
	print("printing user ID in handle request completed: ", id)
	get_node("/root/State").set_user_id(id)

func request_new_attempt_session_id(args):
	print("requesting new attempt session id")
	var headers=["User-Agent: Jeff", "Accept: */*"]
	get_node("AttemptSessionIDRequest").request("http://104.236.237.104/get_new_attempt_session", headers)

func attempt_session_id_request_completed(result, response, headers, body):
	print("bytes got: ",body.size())
	var text = body.get_string_from_ascii()
	var id = int(text)
	print("printing attempt session ID in handle request completed: ", id)
	get_node("/root/State").set_attempt_session_id(id)
	
	
	
	
#	
#func log_online(json_data):
#	print("logging attempt online")
#	var HTTP = HTTPClient.new()
#	var extension = "/IQMcZufUb8e4mArWuTsa"
#	var RESPONSE = HTTP.connect(URL, 80)
#	assert(RESPONSE == OK)
#	
#	while(HTTP.get_status() == HTTPClient.STATUS_CONNECTING or HTTP.get_status() == HTTPClient.STATUS_RESOLVING):
#		HTTP.poll()
#		OS.delay_msec(300)
#	
#	assert(HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
#	var QUERY = json_data
#	var HEADERS = ["User-Agent: Jeff", "Content-Type: application/json"]
#	RESPONSE = HTTP.request(HTTPClient.METHOD_POST, extension, HEADERS, QUERY)
#	assert(RESPONSE == OK)
#	
#	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
#		HTTP.poll()
#		OS.delay_msec(300)
#	#    # Make sure request finished
#	assert(HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED)