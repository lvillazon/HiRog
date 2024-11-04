extends TextureRect

# Set zoom sensitivity
var zoom_step = 0.1
var min_zoom = 0.5  # Minimum zoom level
var max_zoom = 3.0  # Maximum zoom level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _input(event):
	# Check if the event is a scroll wheel event
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func zoom_in():
	scale += Vector2(zoom_step, zoom_step)
	scale.x = clamp(scale.x, min_zoom, max_zoom)
	scale.y = clamp(scale.y, min_zoom, max_zoom)
	pivot_offset = get_local_mouse_position()

func zoom_out():
	scale -= Vector2(zoom_step, zoom_step)
	scale.x = clamp(scale.x, min_zoom, max_zoom)
	scale.y = clamp(scale.y, min_zoom, max_zoom)
