extends RigidBody3D

@onready var GrabTarget = get_tree().get_first_node_in_group("GrabTarget")
@onready var Camera : Camera3D = get_tree().get_first_node_in_group("Camera")

#FLAGS
var grabed : bool = false



func mouse_interaction():
	if Input.is_action_just_pressed("E") and !grabed:
		grab()

func grab():
	freeze = false
	grabed = true

func drop():
	grabed = false
	apply_central_force(-Camera.global_transform.basis.z * 100)

func _process(_delta) -> void:
	if grabed:
		var target_pos = GrabTarget.global_position
		var direction = (target_pos - global_position)
		var distance = direction.length()
		var velocity = direction.normalized() * clamp(distance * 5.0, 0, 20)
		DebugDraw3D.draw_line(global_position, target_pos, Color.FIREBRICK)

		linear_velocity = velocity
		if Input.is_action_just_pressed("left_click"):
			drop()
