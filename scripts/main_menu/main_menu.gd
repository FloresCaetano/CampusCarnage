extends Control



func _on_btn_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test.tscn")


func _on_btn_settings_pressed() -> void:
	$"../Settings".visible = true


func _on_btn_exit_pressed() -> void:
	get_tree().quit(0)
