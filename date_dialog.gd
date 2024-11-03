extends Window

# internally, dates are stored as years relative to common era CE
# -ve numbers are BCE 
# (which should be all of them, unless we start including stuff from the Roman period)
var from_date: int
var to_date: int

const DUMMY_DATE = 9999

@onready var container = $MarginContainer/VBoxContainer
@onready var linFromBCE = container.get_node("HBoxBCE/linFromBCE")
@onready var linToBCE = container.get_node("HBoxBCE/linToBCE")
@onready var linFromYearsOld = container.get_node("HBoxYearsOld/linFromYears")
@onready var linToYearsOld = container.get_node("HBoxYearsOld/linToYears")
@onready var optPeriod = container.get_node("HBoxPeriod/OptionButton")
@onready var butOK = container.get_node("HBoxButtons/butOK")

func parse_int(str: String) -> int:
	if str.is_valid_int():
		return int(str)
	else:
		return DUMMY_DATE
		
func date_to_period(date: int) -> int:
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
	var index: int = 1
	for p in periods:
		if date >= periods[p][0] and date <= periods[p][1]:
			return index
		index += 1
	return 0  # no matching period

# make all date fields refer to the same date range
# converting between different dating systems as required
func sync_dates() -> void:
	var earlyPeriod = 0
	var latePeriod = 0
	
	if from_date != DUMMY_DATE:
		linFromYearsOld.text = str(-1*(from_date-2000))  # roughly, let's not add artificial precision here
		linFromBCE.text = str(-from_date)
		earlyPeriod = date_to_period(from_date)

	if to_date != DUMMY_DATE:
		linToYearsOld.text = str(-1*(from_date-2000))  # roughly, let's not add artificial precision here
		linToBCE.text = str(-from_date)
		latePeriod = date_to_period(to_date)
	
	if earlyPeriod > 0:
		optPeriod.selected = earlyPeriod
	else:
		optPeriod.selected = latePeriod
		


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

#func _on_lin_from_bce_text_changed(new_text: String) -> void:


func _on_lin_from_bce_focus_exited() -> void:
	var result = parse_int(linFromBCE.text)
	if result != DUMMY_DATE:
		from_date = -result  # make it negative for BCE
		sync_dates()
		butOK.disabled = false

func _on_lin_to_bce_focus_exited() -> void:
	var result = parse_int(linToBCE.text)
	if result != DUMMY_DATE:
		to_date = -result  # make it negative for BCE
		sync_dates()
		butOK.disabled = false

func _on_lin_from_years_focus_exited() -> void:
	var result = parse_int(linFromYearsOld.text)
	if result != DUMMY_DATE:
		to_date = -(result + 2000)
		sync_dates()
		butOK.disabled = false

func _on_lin_to_years_focus_exited() -> void:
	var result = parse_int(linToYearsOld.text)
	if result != DUMMY_DATE:
		from_date = -(result + 2000)
		sync_dates()
		butOK.disabled = false
