class_name EnemyAttackState
extends State

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var vision_cast: RayCast3D

@export var shoot_range: float = 8

#FLAGS
var can_reproduce_sound : bool = true
var already_played_animation: bool = false

var timer : Timer

signal lose_player

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	if actor.is_alive:
		set_physics_process(true)

func _exit_state() -> void:
	already_played_animation = true
	can_reproduce_sound = true
	animator.play("aim", -1, -1)
	set_physics_process(false)


func _physics_process(delta: float) -> void:

	if (vision_cast.get_collision_point() - actor.global_position).length() > shoot_range:
		animator.play("run")
		reach_player(delta)
		
	else:
		if not already_played_animation:
			animator.play("aim")
			already_played_animation = true
		actor.look_at(actor.player.global_position + Vector3(0, 1, 0))
		if can_reproduce_sound:
			$"../../AudioStreamPlayer3D".play()
			actor.player.take_damage()
			$"../../AudioStreamPlayer3D".finished.connect(func(): can_reproduce_sound = true)
			can_reproduce_sound = false

	if actor.velocity.length() > 0:
		actor.rotation.y = lerp_angle(
			actor.rotation.y, atan2(-actor.velocity.x, -actor.velocity.z),
			delta * 3
		)
	
	if vision_cast.get_collider() is not Player:
		lose_player.emit()

func reach_player(delta : float) -> void:
	actor.nav.target_position = actor.player.global_position
	var direction = actor.nav.get_next_path_position() - actor.global_position
	direction = direction.normalized() 
	
	actor.velocity = actor.velocity.lerp(direction * actor.MAX_SPEED, actor.acceleration * delta)
	
	actor.move_and_slide()
