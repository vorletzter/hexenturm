extends MarginContainer

var id : int
signal info_clicked

func _ready() -> void:
	pass

func set_bursche_info(bursche: Dictionary, index: int) -> void:
	if bursche["nickname"]:
		$VBoxContainer2/HBoxContainer/VBoxContainer/nickname.text = bursche["nickname"]
	if bursche["name"]:
		$VBoxContainer2/HBoxContainer/VBoxContainer/name.text = bursche["name"]
	if bursche["role"]:
		$VBoxContainer2/HBoxContainer/VBoxContainer/rolle.text = bursche["role"]
	if bursche["quote"]:
		$VBoxContainer2/quote.text = bursche["quote"]
		
	id = index
		
	if bursche["image_preview"]:
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", self, "_http_image_request_completed")
		# Perform the HTTP request. The URL below returns a PNG image as of writing.
		var error = http_request.request(bursche["image_preview"])
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	
	$VBoxContainer2/HBoxContainer/VBoxContainer/info.connect("pressed",self,"_on_info_clicked")
	
func _on_info_clicked() -> void:
	#$AcceptDialog.popup()
	emit_signal("info_clicked", id)

func _http_image_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var image_error = image.load_jpg_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	var texture = ImageTexture.new()
	texture.create_from_image(image, Texture.FLAG_FILTER) # avoid MipMaps on GLES3 Android
	$VBoxContainer2/HBoxContainer/TextureRect.texture = texture
	#$AcceptDialog/TextureRect.texture = texture
	#$VBoxContainer2/HBoxContainer/VBoxContainer/TextureButton.texture_normal = texture

	var sizeto=Vector2(150,150)
	var size=texture.get_size()
	var scale_factor=sizeto/size
	#$Sprite.texture = texture
	#$Sprite.scale=scale_factor
