extends HBoxContainer


func _on_btn_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
