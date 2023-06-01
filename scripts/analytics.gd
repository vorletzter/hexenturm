extends Node

const HEADERS = ["Content-Type: application/json"]
const SESSION_URL = "https://hexenturm.kircheone.de/sessions/"
var tracking_url = ""
var session_id = ""
var profile_id = ""

var has_valid_session = false
var analytics_enabled = false

onready var l = Logger.new("analytics.gd")

enum verbs {
	UNDECLARED, # default
	CLICKED, # UI
	SELECTED, # UI
	CLOSED, # UI
	OPEND, #UI 
	DIED, # Player
	COLLECTED, # Player
	USED, # Player
	RESPAWNED, # Player
	ACTION, # Player
	SEND, # Net
	RECIEVED # Net
	MECHANIC # Game / UI Logic (e.g. get_tree() and such)
	STATISTICS # Statistics (cpu, ...)
	DEBUG # DEBUG Infos
}

func _ready() -> void:
	pass
	
func init_analytics(profile_uuid):
	l.log("Initalising analytics and requesting session", l.levels.ANALYTICS)
	var http_request = HTTPRequest.new()
	var HEADERS = ["Content-Type: application/json"]
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_new_session")
	var json_body = to_json({"profile": profile_uuid  }) 
	var error = http_request.request(SESSION_URL, HEADERS, true, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		l.log("An error occurred in the HTTP request", l.levels.ERROR)
		#push_error("An error occurred in the HTTP request.")

		
func _http_request_new_session(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error == OK:
		var data_received = json.result
		if data_received.has('profile') && data_received.has('id'):
			profile_id = data_received['profile']
			session_id = data_received['id']
			l.log("Using session_id: "+ session_id, l.levels.ANALYTICS)
			tracking_url = str(SESSION_URL)+str(session_id)+"/activities/"
			has_valid_session = true
		else:
			l.log("invalid session | disable analytics: "+ session_id, l.levels.ANALYTICS)
			has_valid_session = false
		
	
func post(verb: int = verbs.UNDECLARED, object: String = "", freetext = null):
	if !analytics_enabled:
		l.log("Error uploading analytics data: Disabled."+ session_id, l.levels.ANALYTICS)
		return
		if !has_valid_session:
			l.log("Error uploading analytics data: Invalid Session ["+ session_id + "].", l.levels.ANALYTICS)
			return
	_post_data({"verb": verb, "object": object, "freetext": freetext})
			
	
# Called when the HTTP request is completed.
func _http_request_completed_activity(_result, response_code, _headers, _body):
	if response_code != 201:
		l.log("Error uploading analytics data "+ session_id, l.levels.ANALYTICS)

func _post_data(body: Dictionary):
	var json_body = to_json(body)
	l.log("POST to ", l.levels.ANALYTICS)
	l.log("\t URL: "+tracking_url, l.levels.ANALYTICS)
	l.log("\t DATA: "+str(json_body), l.levels.ANALYTICS)
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed_activity")
	var error = http_request.request(tracking_url, HEADERS, true, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
		

