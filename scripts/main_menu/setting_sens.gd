extends HBoxContainer

@onready var ctl_slider : HSlider = $HSlider
@onready var ctl_sens_line : LineEdit = $LineEdit

func _ready() -> void:
	ctl_sens_line.text = str(ctl_slider.value)
	
	ctl_slider.connect("value_changed", func(value): ctl_sens_line.text = str(value); GLOBAL.change_sensitivity(value))
	
	GLOBAL.change_sensitivity(ctl_slider.value)
