class_name EnemyDeadState
extends State

@export var actor: Enemy
@export var animator: AnimationPlayer

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	if actor.is_alive:
		animator.stop()
		animator.play("dead")
		actor.is_alive = false
		set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)
