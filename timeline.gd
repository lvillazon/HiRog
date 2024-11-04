extends Control

@onready var font = preload("res://fonts/Nunito/Nunito-Light.ttf")

# Chronology based on Shaw(2000)
# https://en.wikipedia.org/wiki/Egyptian_chronology
var milestones = [
	["Great Pyramids", -2650],
	["Book of the Dead", -1700],
	["Tutankhamun", -1336],
	["Cleopatra", -51],
	]

var periods = {
	"Early Period":     [-3150, -2686],
	"Old Kingdom":      [-2686, -2181],
	"1st Intermediate": [-2181, -2061],
	"Middle Kingdom":   [-2061, -1649],
	"2nd Intermediate": [-1705, -1549],
	"New Kingdom":      [-1549, -1077],
	"3rd Intermediate": [-1069,  -653],
	"Late Period":      [-672,   -332],
	"Hellenistic":      [-332,    -30]
	}

var earliest_date = -3200
var latest_date = 0

var artefact_dates = [-1550, -1292]

func _ready():
	# connect the signal that passes the date range of the current artefact
	get_parent().get_parent().connect("send_artefact_dates", Callable(self, "_on_artefact_date_received"))
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
	
# converts a date in BCE to an x-coord on the timeline
func timeline_position(date: int) -> int:
	var size = get_rect().size
	var timeline_start_x = size.x * 0.01
	var timeline_end_x = size.x * 0.99
	var pixels_per_year = (timeline_end_x - timeline_start_x) / (earliest_date - latest_date)
	return timeline_end_x - date * pixels_per_year

func draw_timeline():
	# draw the timeline of Egyptian history
	var line_color = rgb_to_color(230, 153, 0)
	var text_color = rgb_to_color(0, 0, 0)
	var artefact_color = rgb_to_color(199, 132, 101, 128)
	var timeline_thickness = 3
	var tick_thickness = 2
	var size = get_rect().size
	var timeline_height = size.y * 0.5
	var timeline_start = Vector2(timeline_position(earliest_date), timeline_height)
	var timeline_end = Vector2(timeline_position(latest_date), timeline_height)
	var font_size = 10

	draw_line(timeline_start, timeline_end, line_color, timeline_thickness)  # base line
	# tick marks for the periods
	var tick_y = size.y * 0.75
	for p_name in periods:
		var start_x = timeline_position(periods[p_name][0])
		var end_x = timeline_position(periods[p_name][1])
		draw_line(Vector2(start_x, timeline_height), Vector2(start_x, tick_y), line_color, tick_thickness)
		draw_line(Vector2(end_x, timeline_height), Vector2(end_x, tick_y), line_color, tick_thickness)

		# render period text in the middle
		var text_size = font.get_string_size(p_name,HORIZONTAL_ALIGNMENT_CENTER,-1,font_size)
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
			text_color
			)
			
	# tick marks for the millennia
	for year in range(-3000, 1, 1000):
		var year_label = str(-year)+" BCE"
		var text_size = font.get_string_size(year_label,HORIZONTAL_ALIGNMENT_CENTER,-1,font_size)
		var x = timeline_position(year)
		draw_line(Vector2(x, timeline_height/1.5), Vector2(x, timeline_height), line_color, tick_thickness)

		# render millenium label, next to the tick
		# clamp to make sure labels don't 'leak' past the timeline
		var centred_x = clamp(
			x - text_size.x / 2, 
			timeline_start.x+text_size.x, 
			timeline_end.x-text_size.x) 
		var text_y = timeline_height/2
		draw_string(
			font, 
			Vector2(centred_x, text_y), 
			year_label,
			HORIZONTAL_ALIGNMENT_LEFT, 
			-1,	
			10, 
			text_color
			)
					
	# draw a bar to indicate the date range of the current artefact
	var start_pos = timeline_position(artefact_dates[0])
	var end_pos = timeline_position(artefact_dates[1])
	var date_top_left = Vector2(start_pos, timeline_height/1.5)
	var date_size = Vector2(end_pos-start_pos, tick_y/3)
	var artefact_rect = Rect2(date_top_left, date_size)
	draw_rect(artefact_rect, artefact_color, true)
	
func _on_artefact_date_received(dates):
	print("receiving date packet:", dates)
	artefact_dates = dates
	
