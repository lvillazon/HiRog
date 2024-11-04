extends Window

# internally, dates are stored as years relative to common era CE
# -ve numbers are BCE 
# (which should be all of them, unless we start including stuff from the Roman period)
var from_date: int
var to_date: int

const DUMMY_DATE = 9999

# signal to send the chosen date back to the main window
signal send_date(date_packet)

@onready var container = $MarginContainer/VBoxContainer
@onready var linFromBCE = container.get_node("HBoxBCE/linFromBCE")
@onready var linToBCE = container.get_node("HBoxBCE/linToBCE")
@onready var chkBCE = container.get_node("HBoxBCE/chkBCESelected")

@onready var linFromYearsOld = container.get_node("HBoxYearsOld/linFromYears")
@onready var linToYearsOld = container.get_node("HBoxYearsOld/linToYears")
@onready var chkYearsOld = container.get_node("HBoxYearsOld/chkYearsOldSelected")

@onready var linDynasty = container.get_node("HBoxDynasty/linDynasty")
@onready var chkDynasty = container.get_node("HBoxDynasty/chkDynastySelected")

@onready var optPeriod = container.get_node("HBoxPeriod/optPeriod")
@onready var chkPeriod = container.get_node("HBoxPeriod/chkPeriodSelected")

@onready var butOK = container.get_node("HBoxButtons/butOK")

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

var dynasties = [
	# Early Dynastic Period
	["1st", -3100, -2890],
	["2nd", -2890, -2686],
	
	# Old Kingdom
	["3rd", -2686, -2613],
	["4th", -2613, -2494],
	["5th", -2494, -2345],
	["6th", -2345, -2181],
	
	# First Intermediate Period
	["7th", -2181, -2160],
	["8th", -2160, -2130],
	["9th/10th", -2130, -2055],
	["9th/10th", -2130, -2055],
	
	# Middle Kingdom
	["11th", -2055, -1985],
	["12th", -1985, -1773],
	["13th", -1773, -1650],
	
	# Second Intermediate Period
	["14th", -1650, -1630],
	["15th (Hyksos)", -1630, -1523],
	["16th", -1650, -1580],
	["17th", -1580, -1550],
	
	# New Kingdom
	["18th", -1550, -1292],
	["19th", -1292, -1189],
	["20th", -1189, -1077],
	
	# Third Intermediate Period
	["21st", -1077, -943],
	["22nd (Libyan)", -943, -716],
	["23rd", -837, -728],
	["24th", -732, -720],
	["25th (Kushite)", -747, -656],
	
	# Late Period
	["26th (Saite)", -664, -525],
	["27th (Persian)", -525, -404],
	["28th", -404, -399],
	["29th", -399, -380],
	["30th", -380, -343],
	["31st (Persian)", -343, -332],
	
	# Ptolemaic Period
	["Ptolemaic", -332, -30],
	
	# Roman Period
	["Roman", -30, 2000]  # Egypt becomes a Roman province from 30 BCE onward
]

func parse_int(str: String) -> int:
	if str.is_valid_int():
		return int(str)
	else:
		return DUMMY_DATE

func absolute_date_to_dynasty_name(date: int) -> String:
	var index: int = 0
	for d in dynasties:
		if date >= d[1] and date <= d[2]:
			return d[0]
	return ""  # no matching dynasty

func absolute_date_to_period(date: int) -> int:
	var index: int = 1  # 0 is the "select period" prompt, in the drop down
	for p in periods:
		if date >= periods[p][0] and date <= periods[p][1]:
			return index
		index += 1
	return 0  # no matching period

func years_old_to_absolute_date(years: int) -> int:
	return 2000 - years  # using 2000 as the approximation for current year
	
func absolute_date_to_BCE(date: int) -> int:
	return -date  # 100BCE is the date -100
	
func BCE_to_absolute_date(bce: int) -> int:
	return -bce
	
func absolute_date_to_years_old(date: int) -> int:
	return absolute_date_to_BCE(date) + 2000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	from_date = DUMMY_DATE
	to_date = DUMMY_DATE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_but_cancel_pressed() -> void:
	# TODO reset the input fields? Or is it better to leave them?
	hide()  # close dialog without signalling the main window

func _on_but_ok_pressed() -> void:
	# return the date in the selected format
	var date_text
	if chkYearsOld.button_pressed == true:
		date_text = linFromYearsOld.text + " to " + linToYearsOld.text + " years old"
	elif chkBCE.button_pressed == true:
		date_text = linFromBCE.text + " - " + linToBCE.text + "BCE"
	elif chkDynasty.button_pressed == true:
		date_text = linDynasty.text + " dynasty"
	elif chkPeriod.button_pressed == true:
		date_text = periods.keys()[optPeriod.selected-1]
	else:
		date_text = ""
	var date_packet = [date_text, from_date, to_date]
	emit_signal("send_date", date_packet)
	hide()

func _on_lin_from_bce_focus_exited() -> void:
	var result = parse_int(linFromBCE.text)
	if result != DUMMY_DATE:
		from_date = BCE_to_absolute_date(result)
		linToYearsOld.text = str(absolute_date_to_years_old(from_date))
		linDynasty.text = absolute_date_to_dynasty_name(from_date)
		optPeriod.selected = absolute_date_to_period(from_date)
		chkBCE.button_pressed = true
		butOK.disabled = false

func _on_lin_to_bce_focus_exited() -> void:
	var result = parse_int(linToBCE.text)
	if result != DUMMY_DATE:
		to_date = BCE_to_absolute_date(result)
		linFromYearsOld.text = str(absolute_date_to_years_old(to_date))
		linDynasty.text = absolute_date_to_dynasty_name(to_date)
		optPeriod.selected = absolute_date_to_period(to_date)
		chkBCE.button_pressed = true
		butOK.disabled = false

func _on_lin_from_years_focus_exited() -> void:
	var result = parse_int(linFromYearsOld.text)
	if result != DUMMY_DATE:
		to_date = years_old_to_absolute_date(result)
		linToBCE.text = str(absolute_date_to_BCE(to_date))
		linDynasty.text = absolute_date_to_dynasty_name(to_date)
		optPeriod.selected = absolute_date_to_period(to_date)
		chkYearsOld.button_pressed = true
		butOK.disabled = false

func _on_lin_to_years_focus_exited() -> void:
	var result = parse_int(linToYearsOld.text)
	if result != DUMMY_DATE:
		from_date = years_old_to_absolute_date(result)
		linFromBCE.text = str(absolute_date_to_BCE(from_date))
		linDynasty.text = absolute_date_to_dynasty_name(from_date)
		optPeriod.selected = absolute_date_to_period(from_date)
		chkYearsOld.button_pressed = true
		butOK.disabled = false

func _on_lin_dynasty_focus_exited() -> void:
	# grab just the numeric chars from the start - to avoid the 'st' in '1st'
	var digit1 = parse_int(linDynasty.text[0])
	if digit1 != DUMMY_DATE:
		var result = digit1
		if len(linDynasty.text)>1:
			var digit2 = parse_int(linDynasty.text[1])
			if digit2 != DUMMY_DATE:
				result = digit1*10 + digit2
				
		if result >=1 and result <=len(dynasties):
			# lookup the start/end dates for this dynasty
			linDynasty.text = dynasties[result-1][0]
			from_date = dynasties[result-1][1]
			to_date = dynasties[result-1][2]
			linFromYearsOld.text = str(absolute_date_to_years_old(to_date))
			linToYearsOld.text = str(absolute_date_to_years_old(from_date))
			linFromBCE.text = str(absolute_date_to_BCE(from_date))
			linToBCE.text = str(absolute_date_to_BCE(to_date))
			optPeriod.selected = absolute_date_to_period(from_date)
			chkDynasty.button_pressed = true
			butOK.disabled = false

func _on_opt_period_item_selected(index: int) -> void:
	if index >0:  # 0 doesn't count -it's just the drop down prompt
		var period_name = periods.keys()[index]
		from_date = periods[period_name][0]
		to_date = periods[period_name][1]
		linFromBCE.text = str(absolute_date_to_BCE(from_date))
		linToBCE.text = str(absolute_date_to_BCE(to_date))
		linFromYearsOld.text = str(absolute_date_to_years_old(to_date))
		linToYearsOld.text = str(absolute_date_to_years_old(from_date))
		linDynasty.text = absolute_date_to_dynasty_name(from_date) + " - " + absolute_date_to_dynasty_name(to_date)
		chkPeriod.button_pressed = true
		butOK.disabled = false
		
