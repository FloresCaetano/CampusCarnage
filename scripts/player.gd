class_name Player
extends CharacterBody3D
#
var drag_data
var drag_target_data
@onready var Pivote = $Pivot
@onready var Camera = $Pivot/Camera3D
@onready var MouseRayCast = $Pivot/Camera3D/MouseRayCast

#FLAGS
var can_move : bool = true
var can_jump : bool = true
var is_jumping : bool = false
var on_debug := false
var can_footstep : bool = true

#MOVE
var max_speed = 10
var acceleration = 0.5
var desaceleration = 0.5

#JUMP
var max_height = 0.7
var jump_strength : float = 2
var reference_jump_height : float
var gravity = 25 #25

#STAIRS
const MAX_STEP_HEIGHT = 0.2
var _snaped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

func _physics_process(delta):
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	move(delta, get_input())

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	%StairsBelowRaycast.force_raycast_update()
	var floor_below : bool = %StairsBelowRaycast.is_colliding() and not is_surface_too_step(%StairsBelowRaycast.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_on_floor
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snaped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new()
		if self.test_move(self.global_transform, Vector3(0,-MAX_STEP_HEIGHT,0), body_test_result):
			#_save_camera_pos_for_smoothing()
			var translate_y = body_test_result.get_travel().y
			position += Vector3(0, translate_y, 0)
			apply_floor_snap()
			did_snap = true
	_snaped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snaped_to_stairs_last_frame: return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	# Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	#  We give some clearance above to ensure there's ample room for the player.
	#  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	#  along with their intended motion forward.
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") and down_check_result.get_collider().is_in_group("climbeable"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		%StairsRaycast.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		%StairsRaycast.force_raycast_update()
		if %StairsRaycast.is_colliding() and not is_surface_too_step(%StairsRaycast.get_collision_normal()):
			var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "global_position", step_pos_with_clearance.origin + down_check_result.get_travel(), 0.1)
			apply_floor_snap()
			_snaped_to_stairs_last_frame = true
			return true
	return false

func is_surface_too_step(normal : Vector3):
	return normal.angle_to(Vector3.UP) > self.floor_max_angle
	
func _run_body_test_motion(from: Transform3D, motion : Vector3, result = null):
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func move(delta, input):
	var impulse = Vector3(
		transform.basis.x.x * input.x + transform.basis.z.x * input.z,
		0,
		transform.basis.x.z * input.x + transform.basis.z.z * input.z
		).normalized() * max_speed
	velocity.y -= gravity * delta
	if input.x != 0 or input.z != 0:
		#play_footsteps()
		velocity.x = lerp(velocity.x, impulse.x, acceleration)
		velocity.z = lerp(velocity.z, impulse.z, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, desaceleration)
		velocity.z = lerp(velocity.z, 0.0, desaceleration)
	
	if not _snap_up_stairs_check(delta):
		move_and_slide()
		_snap_down_to_stairs_check()

func get_input():
	var input = Vector3()
	if can_move:
		if Input.is_action_pressed("W"):
			input.z += 1
		if Input.is_action_pressed("S"):
			input.z -= 1
		if Input.is_action_pressed("A"):
			input.x += 1
		if Input.is_action_pressed("D"):
			input.x -= 1
		if Input.is_action_pressed("Space"):
			input.y += 1
		if Input.is_action_pressed("Shift"):
			input.y -= 1
	return input

func play_footsteps():
	if can_footstep:
		var sound : String
		var creaking : String
		if $CheckFloorMaterialRay.get_collider() != null:
			if $CheckFloorMaterialRay.get_collider().is_in_group("wood"):
				$FootstepsPlayer.bus = "HighReverb"
				sound = "res://assets/audio/fx/footsteps/wood/" + str(randi() % 3 + 1) + ".mp3"
				creaking = "res://assets/audio/fx/footsteps/wood/c" + str(randi() % 3 + 1) + ".mp3"
				if((randi() % 10 + 1) == 3):
					$"FootstepsPlayer(creaking)".stream = load(creaking)
					$"FootstepsPlayer(creaking)".play()
			elif $CheckFloorMaterialRay.get_collider().is_in_group("grass"):
				$FootstepsPlayer.bus = "Master"
				sound = "res://assets/audio/fx/footsteps/grass/1.mp3"
				$FootstepsPlayer.pitch_scale = randf_range(0.7, 1)
			else:
				return
		else:
			return
		$FootstepsPlayer.stream = load(sound)
		$FootstepsPlayer.play()
		can_footstep = false
		$FootstepsTimer.start()

func desactivate():
	can_move = false
	Pivote.cameraLock = true

func activate():
	can_move = true
	Pivote.cameraLock = false

func _on_footsteps_timer_timeout():
	can_footstep = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("Escape"):
		var _is_visible = %Settings.visible
		if _is_visible:
			%Settings.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Pivote.cameraLock = false
		else:
			%Settings.visible =  true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Pivote.cameraLock = true


func take_damage():
	$Hud/AnimationPlayer.stop()
	$Hud/AnimationPlayer.play("take_damage")
