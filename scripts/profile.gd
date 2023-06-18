extends Node

const HEADERS = ["Content-Type: application/json"]
const SERVER = "https://hexenturm.kircheone.de"
#const SERVER = "http://localhost:8000"
const HIGHSCORE_URL = SERVER+"/highscores/"
const BURSCHEN_URL = SERVER+"/burschen/"
const PROFILE_URL = SERVER+"/profiles/"
const SCORE_URL = SERVER+"/scores/"

var PROFILE_UUID = "null"
var PROFILE_NAME = ""

var PROFILE_IS_VALID = false # set to true after successfull api request

var upload_score_enabled = true
var analytics_enabled = true

var network_error : int = 0
var network_errors : int = 0

#var NETWORK_ENABLED = false

enum SETTINGS {
	name,
	auto_score,
	analytics,
}

onready var l = Logger.new("profile.gd")

func _ready() -> void:
	check_and_load_or_create_web_profile()
	
func create_new_web_profile() -> void:
	var device_info = {"device_name": OS.get_name(),
		"max_screen": OS.get_screen_size(),
		"processor_name": OS.get_processor_name(),
		"video_adapter": str(VisualServer.get_video_adapter_vendor())+"|"+str(VisualServer.get_video_adapter_name())}
		
	l.log("Found no uuid for profile on disk. Requesting new uuid from API.", l.levels.INFO)
	_post_data(PROFILE_URL, {"device_info": device_info}, "_http_request_completed_recv_profile", true)

func check_and_load_or_create_web_profile():
	var uuid = load_uuid_from_disk()
	if uuid == "":
		create_new_web_profile()
	else:
		Global.first_start = false
		l.log("Found Profile UUID: "+uuid+"; Checking.", l.levels.INFO)
		_get_data(PROFILE_URL+uuid, "_http_request_completed_recv_profile")
	pass
	
# 
# Submitting a Score to the Profile
#
func submit_score(score : int, levels: int, score_meta: Dictionary):
	if upload_score_enabled:
		l.log("Sending Score to API", l.levels.INFO)
		_send_score(score, levels, score_meta)
	else:
		l.log("Sending Score disabled", l.levels.INFO)

func _send_score(score : int, levels : int, score_meta: Dictionary):
	_post_data(PROFILE_URL+PROFILE_UUID+"/scores/", {"score": str(score), "stages": str(levels), "score_meta": score_meta})

func get_highscore(page: int = 1):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(HIGHSCORE_URL+"?page="+(str(page)), HEADERS, true, HTTPClient.METHOD_GET)
	var result = yield(http_request, "request_completed")
	return result
	#http_request.connect("request_completed", self, recFunction)
	
func get_player_scores(page: int = 1):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(PROFILE_URL+"/"+PROFILE_UUID+"/scores/"+"?page="+(str(page)), HEADERS, true, HTTPClient.METHOD_GET)
	print (PROFILE_URL+PROFILE_UUID+"/scores/")
	var result = yield(http_request, "request_completed")
	return result
	#http_request.connect("request_completed", self, recFunction)
# 
# Misc
#
	
func get_burschen(page: int = 1):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(BURSCHEN_URL+"?page="+(str(page)), HEADERS, true, HTTPClient.METHOD_GET)
	var result = yield(http_request, "request_completed")
	return result
	#http_request.connect("request_completed", self, recFunction)

# 
# Setting Settings
#
func set_name(name):
	PROFILE_NAME = name
	submit_setting(SETTINGS.name,  name)
	
func set_analytics(value: bool):
	submit_setting(SETTINGS.analytics, value)
	if !Analytics.has_valid_session && PROFILE_IS_VALID:
		Analytics.init_analytics(PROFILE_UUID)
	Analytics.analytics_enabled = value

func set_upload_score(value: bool):
	upload_score_enabled = value
	submit_setting(SETTINGS.auto_score, value)
# General Send function
func submit_setting(setting: int, value):
	_put_data(PROFILE_URL+PROFILE_UUID+"/", {SETTINGS.keys()[setting] : value})

# 
# General Networking Stuff
#
func _get_data(url: String, recFunction="_http_request_completed"):
	#l.log("GET to ", l.levels.NETWORKING)
	#l.log("\t URL: "+url, l.levels.NETWORKING)
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, recFunction)
	http_request.request(url, HEADERS, true, HTTPClient.METHOD_GET)

func _put_data(url: String, body : Dictionary, recFunction="_http_request_completed"):
	if PROFILE_IS_VALID:
		var json_body = to_json(body)
		#l.log("PUT to ", l.levels.NETWORKING)
		#l.log("\t URL: "+url, l.levels.NETWORKING)
		#l.log("\t DATA: "+str(json_body), l.levels.NETWORKING)
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", self, recFunction)
		http_request.request(url, HEADERS, true, HTTPClient.METHOD_PUT, json_body)
	else: 
		l.log("Something is trying to send data while the Network is disabled.", l.levels.NETWORKING)

func _post_data(url: String, body: Dictionary, recFunction="_http_request_completed", network_enabled_overwrite=PROFILE_IS_VALID):
	if network_enabled_overwrite:
		var json_body = to_json(body)
		#l.log("POST to ", l.levels.NETWORKING)
		#l.log("\t URL: "+url, l.levels.NETWORKING)
		#l.log("\t DATA: "+str(json_body), l.levels.NETWORKING)
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", self, recFunction)
		http_request.request(url, HEADERS, true, HTTPClient.METHOD_POST, json_body)
	else: 
		l.log("Something is sending data while the Network is disabled.", l.levels.NETWORKING)

# Default function for recieving data. Called if no other function is given for a network request
func _http_request_completed(_result, response_code, _headers, body):
	l.log("Unhandled _http_request_completed: " + str(response_code) , l.levels.NETWORKING)
	if response_code == 0:
		l.log("\t Error in Communication. Server down?" , l.levels.NETWORKING)
	if response_code == 201 or response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		if json.error == OK:
			l.log("\t Data: "+str(json.result) , l.levels.NETWORKING)
		else: 
			l.log("\t Failed to decode Data.", l.levels.NETWORKING)
		# Remove processing.. for now it stays here as a reference
	else:
		l.log("rror in Network Communication in _http_request_completed" + str(response_code) , l.levels.NETWORKING)
		#push_warning("Error in Network Communication: profile.gd/_http_request_completed()")
	return	
	
# Some special revc functions
func _http_request_completed_recv_profile(_result, response_code, _headers, body):
	l.log("Recieved profile_http_response: " + str(response_code) , l.levels.NETWORKING)
	l.log("\t Data: "+body.get_string_from_utf8() , l.levels.NETWORKING)
	if response_code != 404:
		var json = JSON.parse(body.get_string_from_utf8())
		if json.error == OK:
			var data_received = json.result
			if data_received.has('id') && data_received.has('name') && data_received.has('analytics') && data_received.has('auto_score'):
				l.log("Profile is valid. UUID: '"+data_received['id']+"'", l.levels.INFO)
				PROFILE_IS_VALID = true
				PROFILE_UUID = data_received['id']
				PROFILE_NAME = data_received['name']
				analytics_enabled = data_received['analytics']
				upload_score_enabled = data_received['auto_score']
				if analytics_enabled:
					Analytics.init_analytics(PROFILE_UUID)
					Analytics.analytics_enabled = true
				if data_received.has('highscore'):
					Achievements.highscore = data_received['highscore']
				
					
				save_uuid_to_disk(PROFILE_UUID) #ToDo. As of now we safe the profil, even if we have loaded it bevor.
			else:
				l.log("Recieved invalid profile data: wrong entrys recieved.", l.levels.ERROR)
				#push_warning("Recived invalid profile: profile.gd/_http_request_completed_recv_profile")
		else:
			l.log("Recieved invalid profile data: could not parse json.", l.levels.ERROR)
			#push_warning("Could not parse json: profile.gd/_http_request_completed_recv_profile")
	else:
		l.log("API could not find profile. Creating a new one.", l.levels.INFO)
		network_errors += 1
		if network_errors < 3:
			create_new_web_profile()
		else:
			l.log("To many network errors. Disabling WebProfile", l.levels.ERROR)
		
		#_post_data(PROFILE_URL, {}, "_http_request_completed_recv_profile", true)

# 
# Writing/Reading Profile Data from the Filesystem
#
func save_uuid_to_disk(uuid: String):
	var config = ConfigFile.new()
	#var err = config.load("user://profile.cfg")
	config.set_value("Profile", "uuid", uuid)
	var err = config.save("user://profile.cfg")
	if err != OK:
		l.log("Error opening profile.cfg: "+PROFILE_UUID, l.levels.WARNING)
	else:
		l.log("Saved Profile uuid to disk: "+PROFILE_UUID, l.levels.INFO)
	
func load_uuid_from_disk() -> String:
	var config = ConfigFile.new()
	var err = config.load("user://profile.cfg")
	if err != OK:
		l.log("Error opening profile.cfg:" , l.levels.WARNING)
		return ""
	return config.get_value("Profile", "uuid", "")
