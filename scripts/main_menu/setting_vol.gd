extends HBoxContainer

@onready var ctl_slider : HSlider = $HSlider


func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
