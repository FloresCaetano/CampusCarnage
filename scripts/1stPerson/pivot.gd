extends Node3D

var mouse_delta = Vector2()
var min_look_angle : float = -75
var max_look_angle : float = 80
var cameraLock : bool = false

@onready var player = $".."
@onready var camera = $Camera3D

#BOBBING
var bobbing_amount = 0.09  # Amplitude
var bobbing_speed = 13.0    # Frecuency
var bobbing_timer = 0.0
var base_camera_position = Vector3.ZERO

func _ready():
	base_camera_position = position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if !cameraLock:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			player.rotate_y(deg_to_rad(-event.relative.x * GLOBAL.look_sensitivity))
			rotate_x(deg_to_rad(event.relative.y * GLOBAL.look_sensitivity))
			rotation_degrees.x = clamp(rotation_degrees.x, -89, 89)
	
	camera_tilt(player.get_input().x)

func camera_tilt(input : int):
	var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(set_camera_rotation_z, camera.rotation_degrees.z, input, 0.2)
	
func set_camera_rotation_z(value : float):
	camera.rotation_degrees.z = value

func bobbing(delta):
	if player.velocity != Vector3.ZERO and player.is_on_floor():
		bobbing_timer += delta * bobbing_speed
		var bob_offset = sin(bobbing_timer) * bobbing_amount
		position.y = base_camera_position.y + bob_offset
	else:
		# Volver a posición original si no hay movimiento
		position.y = lerp(position.y, base_camera_position.y, delta * 10)
		bobbing_timer = 0.0  # Opcional: resetear para evitar saltos bruscos


func _process(delta: float) -> void:
	bobbing(delta)
