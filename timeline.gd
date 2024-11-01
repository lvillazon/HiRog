extends Control

@onready var font = preload("res://fonts/Nunito/Nunito-Light.ttf")

# Chronology based on Shaw(2000)
# https://en.wikipedia.org/wiki/Egyptian_chronology
var dynasties = {
	1: [3100, 2900],
	2: [2890, 2686],
	3: [2686, 2613],
	4: []
}
var periods = {
	"Early Period": [3150, 2686],
	"Old Kingdom": [2686, 2181],
	"1st Intermediate": [2181, 2061],
	"Middle Kingdom": [2061, 1649],
	"2nd Intermediate": [1705, 1549],
	"New Kingdom": [1549, 1077],
	"3rd Intermediate": [1069, 653],
	"Late Period": [672, 332],
	"Hellenistic": [332, 30]
}
#var periods = {
	#"1": [3150, 2686],
	#"2": [2686, 2181],
	#"3": [2181, 2061],
	#"4": [2061, 1649],
	#"5": [1705, 1549],
	#"6": [1549, 1077],
	#"7": [1069, 653],
	#"8": [672, 332],
	#"9": [332, 30]
#}

var earliest_date = 3200
var latest_date = 0


func _ready():
	# Ensure the node is redrawn if it needs to update (e.g., on resize)
	queue_redraw()

# Override the _draw() function
func _draw():
	draw_timeline()

func _process(delta):
	# Call update() if you need to redraw on every frame (for animations)
	queue_redraw()
	
func rgb_to_color(r, g, b, a=255):
	return Color(r / 255.0, g / 255.0, b / 255.0, a / 255.0)

func draw_timeline():
	# draw the timeline of Egyptian history
	var line_color = rgb_to_color(230, 153, 0)
	var timeline_thickness = 3
	var tick_thickness = 2
	var size = get_rect().size
	var timeline_height = size.y * 0.5
	var timeline_start = Vector2(size.x * 0.01, timeline_height)
	var timeline_end = Vector2(size.x * 0.99, timeline_height)
	var pixels_per_year = (timeline_end.x - timeline_start.x) / (earliest_date - latest_date)
	draw_line(timeline_start, timeline_end, line_color, timeline_thickness)  # base line
	# tick marks for the periods
	var tick_y = size.y * 0.75
	for p_name in periods:
		var start_x = timeline_end.x - periods[p_name][0] * pixels_per_year
		var end_x = timeline_end.x - periods[p_name][1] * pixels_per_year
		draw_line(Vector2(start_x, timeline_height), Vector2(start_x, tick_y), line_color, tick_thickness)
		draw_line(Vector2(end_x, timeline_height), Vector2(end_x, tick_y), line_color, tick_thickness)

		# render period text in the middle
		var text_size = font.get_string_size(p_name)
		var centred_x = (end_x - start_x)/2 + start_x - text_size.x / 2
		var text_y = tick_y
		if p_name.contains("Intermediate"):  # draw the intermediate period labels lower
			text_y = tick_y + size.y /6
		draw_string(
			font, 
			Vector2(centred_x, text_y), 
			p_name,
			HORIZONTAL_ALIGNMENT_LEFT, 
			-1,	
			10, 
			line_color
			)
