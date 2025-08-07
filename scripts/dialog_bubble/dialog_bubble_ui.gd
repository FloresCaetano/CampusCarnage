class_name DialogBubble
extends Control

signal dialogue_ends

@export var write_speed_per_100_chars = 2
@onready var label: Label = $MarginContainer/Panel/Label

var actual_write_speed # Tiempo total en segundos para escribir el texto completo, basado en write_speed_per_100_chars.
var dialog_lenght

@onready var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
var dialogues : Array[String] = []

#STATES
var can_pass_dialog : bool = false

func _ready() -> void:
	set_process_input(false)

func _calculate_actual_write_speed():
	dialog_lenght = label.text.length()
	actual_write_speed =  (dialog_lenght / 100) * write_speed_per_100_chars

func set_dialogues(_dialogues : Array[String]):
	dialogues = _dialogues

func start_dialog():
	self.visible = true
	set_process_input(true)
	
	if dialogues.is_empty():
		leave_dialog()
		return
	
	label.text = dialogues.pop_front()
	_calculate_actual_write_speed()
	animate_text()

func animate_text():
	tween.tween_property(label, "visible_characters", dialog_lenght, actual_write_speed)
	tween.tween_callback(func(): can_pass_dialog = true)

func _input(event: InputEvent) -> void:
	if event.is_action_released("E"):
		if tween.is_running():
			skip_animation()
		elif can_pass_dialog:
			start_dialog()

func skip_animation():
	tween.stop()
	label.visible_characters = dialog_lenght

func leave_dialog():
	self.visible = false
	dialogue_ends.emit()
	set_process_input(false)
