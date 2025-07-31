class_name EnemyIdleState
extends State

@export var actor: Enemy
@export var animator: AnimationPlayer
@export var vision_cast: RayCast3D

@onready var new_move_point = Vector3(
	actor.global_position.x,
	-0.182,
	actor.global_position.z
)

var timer : Timer

signal saw_player

func _ready() -> void:
	randomize()
	timer = Timer.new()
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(set_new_move_point)
	add_child(timer)
	timer.start(randf_range(5, 20))
	set_physics_process(false)

func _enter_state() -> void:
	if actor.is_alive:
		set_physics_process(true)
		animator.play("idle")

func _exit_state() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var distance = actor.global_position.distance_to(new_move_point)
	if distance > 0.5:
		animator.play("run")
		random_move(new_move_point, delta)
	else:
		animator.play("idle")
	
	if actor.velocity.length() > 0:
		actor.rotation.y = lerp_angle(
			actor.rotation.y, atan2(-actor.velocity.x, -actor.velocity.z),
			delta * 3
		)
	
	if vision_cast.get_collider() is Player:
		saw_player.emit()

func set_new_move_point() -> void:
	new_move_point.x = actor.global_position.x + randf_range(-7, 7)
	new_move_point.z = actor.global_position.z + randf_range(-7, 7)
	timer.start(randf_range(5, 20))

func random_move(target: Vector3, delta : float) -> void:
	
	actor.nav.target_position = target
	var direction = actor.nav.get_next_path_position() - actor.global_position
	direction = direction.normalized() 
	
	actor.velocity = actor.velocity.lerp(direction * actor.MAX_SPEED, actor.acceleration * delta)
	
	actor.move_and_slide()
