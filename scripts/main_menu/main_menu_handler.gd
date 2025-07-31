extends Node3D
@onready var last_scene : Control = $MadeWithGodot

func _on_label_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_tree().change_scene_to_file("res://scenes/test.tscn");

func _ready() -> void:
	%LogoAnim.play("logo_upbeat")
	%bgMusic.play()


func _on_timer_timeout() -> void:
	$BytesLogo.queue_free()
	$MadeWithGodot.queue_free()

func transition(to_scene : Control, duration : float = 1, use_anim : bool = true):
	if use_anim:
		var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(to_scene, "modulate", Color(255, 255, 255, 255), duration)
		tween.tween_callback(func(): last_scene.visible = false)
	else:
		last_scene.visible = false
	


func _on_transition_timer_timeout() -> void:
	transition($BytesLogo)
