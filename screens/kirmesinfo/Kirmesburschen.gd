extends CanvasLayer

var burschen = []
var currentBursche := 0

onready var row_scene = preload("res://screens/kirmesinfo/bursche_info.tscn")
onready var table = $BurschenScrollContainer/BurschenVBoxContainer

func _ready() -> void:
	yield(get_burschen_list(), "completed")	
	
	for i in burschen.size():
		var row = row_scene.instance()
		table.add_child(row)
		row.set_bursche_info(burschen[i], i)
		row.connect("info_clicked", self, "_show_burschen_details")
		
func _show_burschen_details(id : int) -> void:
	if burschen[id]['name']:
		$AcceptDialog.window_title = burschen[id]['name']
		$AcceptDialog/VBoxContainer/name.text = burschen[id]['name']
	if burschen[id]['nickname']:
		$AcceptDialog/VBoxContainer/nickname.text = burschen[id]['nickname']
	if burschen[id]['role']:
		$AcceptDialog/VBoxContainer/rolle.text = burschen[id]['role']
	if burschen[id]['quote']:
		$AcceptDialog/VBoxContainer/quote.text = burschen[id]['quote']
		
	if burschen[id]["image"]:
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", self, "_http_image_request_completed")
		# Perform the HTTP request. The URL below returns a PNG image as of writing.
		var error = http_request.request(burschen[id]["image"])
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	$AcceptDialog.popup()
	
func _http_image_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var image_error = image.load_jpg_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	var texture = ImageTexture.new()
	texture.create_from_image(image, Texture.FLAG_FILTER) # avoid MipMaps on GLES3 Android
	$AcceptDialog/VBoxContainer/TextureRect.texture = texture
	#$VBoxContainer2/HBoxContainer/TextureRect.texture = texture
	
	var sizeto=Vector2(150,150)
	var size=texture.get_size()
	var scale_factor=sizeto/size
		
func _on_Menue_pressed() -> void:
	Analytics.post(Analytics.verbs.CLICKED, "_in_Burschen_on_Menue_pressed")
	get_tree().change_scene("res://screens/StartScreen.tscn")
	pass # Replace with function body.

func get_burschen_list() -> void:
	# todo: get all burschen if if over > 25
	$PopupDialog.popup()
	var result = yield(WebProfile.get_burschen(), "completed")
	var json = JSON.parse(result[3].get_string_from_utf8())
	if json.error == OK:
		var data_received = json.result
		if data_received.has('results'):
			for i in data_received['results']:
				var dic = {"name": i["name"], "nickname" :i["nickname"], "role": i["role"], "quote": i["quote"], "image": i["image"], "image_preview": i["image_preview"]}
				burschen.append(dic)
	$PopupDialog.hide()
