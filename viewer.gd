extends Control

# references to the UI elements
@onready var artefact_pane = $VBox0/HSplit1/VBox1
@onready var info_pane = $VBox0/HSplit1/Margin2/VBox2
#@onready var timeline_pane = 

@onready var next_button = artefact_pane.get_node("HBox1/butNext")
@onready var prev_button = artefact_pane.get_node("HBox1/butPrevious")
@onready var item_image = artefact_pane.get_node("imgOriginal")
@onready var item_hidden = artefact_pane.get_node("HBox1/togHide")
@onready var image_count_label = artefact_pane.get_node("HBox1/labImageCount")

@onready var item_title = info_pane.get_node("txtTitle")
@onready var item_desc = info_pane.get_node("txtDescription")
@onready var item_museum = info_pane.get_node("HBox2/txtMuseum")
@onready var item_date_added = info_pane.get_node("HBox2/txtAdded")
@onready var item_type = info_pane.get_node("HBox3/txtType")
@onready var item_material = info_pane.get_node("HBox3/txtMaterial")
@onready var item_date_origin = info_pane.get_node("txtDate")
@onready var item_place_origin = info_pane.get_node("txtPlace")
@onready var item_translated = info_pane.get_node("txtTranslated")

# metadata keys
const TITLE = "title"				# a short  name
const DESCRIPTION = "description"	# any infotext from the original museum plaque
const LOCATION = "location"			# the museum
const TYPE = "type"					# stone stela, papyrus, sarcophagus etc
const MATERIAL = "material"			# limestone, granite, wood etc
const DATE_ADDED = "added"			# date I 'acquired' it
const DATE_ORIGIN = "date"			# date it is from - this may need to have an upper and lower bound and might need to be expressed in terms of kingdoms or dynasties - might even be unknown
const PLACE_ORIGIN = "place"		# where is it from - again, could have variable precision or be unknown
const TRANSLATED = "translated"		# has it been translated yet? - no, partial translation, complete translation, externally verified
const HIDE_LIST = "hide"			# list of image files to hide from the normal view
# translation text? how will we store this?
# size?

# file paths
const METADATA_FILEPATH = "res://metadata.json"
const IMAGE_PATH = "res://originals//Hieroglyphs"

var images = []
var current_index = 0
var metadata = {}  # holds the info about each exhibit - what, where when etc
var show_hidden = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_metadata()
	load_images(IMAGE_PATH)
	if images.size() > 0:
		display_item(images[current_index])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_images(folder_path: String):
	images = []
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# check its a valid image file
			if !dir.current_is_dir() and (
									file_name.to_lower().ends_with(".png") or
									file_name.to_lower().ends_with(".jpg")
									):
				images.append(folder_path + "/" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	if !show_hidden:
		remove_hidden()

# is this one of the files named on the hide list?
func is_hidden(image_name: String) -> bool:
	if metadata.has(HIDE_LIST) and image_name in metadata[HIDE_LIST]:
		return true
	else:
		return false

# remove images that we should skip, because they are on the list
func remove_hidden():
	for i in range(len(images)-1, -1, -1):
		if is_hidden(images[i]):
			images.remove_at(i)

func update_hidden_list(image_name: String, hidden: bool):
	if hidden:  # add the file to the list
		if !metadata.has(HIDE_LIST):  # create the list if necessary
			metadata[HIDE_LIST] = []
		if !image_name in metadata[HIDE_LIST]:  # don't add if already there
			print("adding " + image_name)
			metadata[HIDE_LIST].append(image_name)
	else:  # remove the file from the list
		print("removing " + image_name)
		metadata[HIDE_LIST].erase(image_name)
	save_metadata()

func load_metadata():
	var file = FileAccess.open(METADATA_FILEPATH, FileAccess.READ)
	if file:
		var json_data = file.get_as_text()
		var json = JSON.new()
		var error_code = json.parse(json_data)
		if error_code == OK:
			metadata = json.data  # data is safe to use
			# add an empty hide list if there isn't already something there
			if !metadata.has(HIDE_LIST):
				metadata[HIDE_LIST] = []
		else:
			print("Error reading JSON metadata:", json.get_error_message())
		file.close()
	else:
		print("Can't open metadata file:", METADATA_FILEPATH)

func save_metadata():
	var file = FileAccess.open(METADATA_FILEPATH, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		var json_text = json.stringify(metadata, "\t")  # pretty print with indentation
		file.store_string(json_text)
		file.close()
	else:
		print("Error writing metadata to", METADATA_FILEPATH)

# return metadata or empty string if not found
func safely_get(item: String, field: String) -> String:
	if metadata.has(item) and metadata[item].has(field):
		return metadata[item][field]
	else:
		return ""
	
func display_item(image_path: String):
	# display the image
	var texture = load(image_path)
	item_image.texture = texture
	image_count_label.text = (
		str(current_index) + " of " + str(images.size()-1)
		)
	
	# display metadata
	print(metadata)  # DEBUG
	var item_key = image_path
	item_title.text = safely_get(item_key, TITLE)
	item_desc.text = safely_get(item_key, DESCRIPTION)
	item_museum.text = safely_get(item_key, LOCATION)
	item_date_added.text = safely_get(item_key, DATE_ADDED)
	item_type.text = safely_get(item_key, TYPE)
	item_material.text = safely_get(item_key, MATERIAL)
	item_date_origin.text = safely_get(item_key, DATE_ORIGIN)
	item_place_origin.text = safely_get(item_key, PLACE_ORIGIN)
	item_translated.text = safely_get(item_key, TRANSLATED)
	item_hidden.button_pressed = is_hidden(item_key)

# add metadata for an item
func update_item(image_filename: String, field: String, value: String):
	if metadata.has(image_filename):
		metadata[image_filename][field] = value
	else:  # create a new entry, since this one doesnt exist yet
		# create default values for all fields 1st
		metadata[image_filename] = {
			TITLE: "",
			DESCRIPTION: "",
			LOCATION: "",
			TYPE: "",				# stone stela, papyrus, sarcophagus etc
			MATERIAL: "unknown",		# limestone, granite, wood etc
			DATE_ADDED: "added",		# date I 'acquired' it
			DATE_ORIGIN: "unknown",		# date it is from - this may need to have an upper and lower bound and might need to be expressed in terms of kingdoms or dynasties - might even be unknown
			PLACE_ORIGIN: "unknown",		# where is it from - again, could have variable precision or be unknown
			TRANSLATED: "no",	# has it been translated yet? - no, partial translation, complete translation, externally verified
		}
		# now set the one that has actually changed
		metadata[image_filename][field] = value
	
	save_metadata()  # write changes to file

func _input(event):
	# simulate button presses for shortcut keys
	if event.is_action_pressed("next_item"):
		next_button.emit_signal("pressed")
	elif event.is_action_pressed("previous_item"):
		prev_button.emit_signal("pressed")

func _on_but_next_pressed() -> void:
	if current_index < images.size():
		current_index = current_index + 1
		display_item(images[current_index])


func _on_but_previous_pressed() -> void:
	if current_index >0 and current_index <= images.size():
		current_index = current_index - 1
		display_item(images[current_index])


func _on_txt_title_text_changed() -> void:
	update_item(images[current_index], TITLE, item_title.text)


func _on_txt_description_text_changed() -> void:
	update_item(images[current_index], DESCRIPTION, item_desc.text)


func _on_txt_museum_text_changed() -> void:
	update_item(images[current_index], LOCATION, item_museum.text)


func _on_txt_added_text_changed() -> void:
	update_item(images[current_index], DATE_ADDED, item_date_added.text)


func _on_txt_type_text_changed() -> void:
	update_item(images[current_index], TYPE, item_type.text)


func _on_txt_material_text_changed() -> void:
	update_item(images[current_index], MATERIAL, item_material.text)


func _on_txt_date_text_changed() -> void:
	update_item(images[current_index], DATE_ORIGIN, item_date_origin.text)


func _on_txt_place_text_changed() -> void:
	update_item(images[current_index], PLACE_ORIGIN, item_place_origin.text)


func _on_txt_translated_text_changed() -> void:
	update_item(images[current_index], TRANSLATED, item_translated.text)


func _on_tog_hide_toggled(toggled_on: bool) -> void:
	update_hidden_list(images[current_index], toggled_on)
	load_images(IMAGE_PATH)

func _on_chk_hidden_toggled(toggled_on: bool) -> void:
	show_hidden = toggled_on
	print("Toggling to ", show_hidden)
	load_images(IMAGE_PATH)
	if images.size() > 0:
		display_item(images[current_index])
