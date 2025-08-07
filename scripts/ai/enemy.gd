class_name Enemy
extends CharacterBody3D

@export var MAX_SPEED = 6.0
@export var acceleration = 10.0
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var nav: NavigationAgent3D = $NavigationAgent3D

#FSM
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var enemy_idle_state: EnemyIdleState = $FiniteStateMachine/EnemyIdleState
@onready var enemy_attack_state: EnemyAttackState = $FiniteStateMachine/EnemyAttackState
@onready var enemy_dead_state: EnemyDeadState = $FiniteStateMachine/EnemyDeadState

var last_saw_player_pos : Vector3 = Vector3.ZERO

#FLAGS
var is_alive : bool = true

func _ready() -> void:
	enemy_idle_state.saw_player.connect(fsm.change_state.bind(enemy_attack_state))
	enemy_attack_state.lose_player.connect(fsm.change_state.bind(enemy_idle_state))


func _physics_process(_delta: float) -> void:
	var player_local_pos = ray_cast_3d.to_local(player.global_position + Vector3(0, 1.5, 0))
	ray_cast_3d.target_position = player_local_pos

func get_fsm() -> FiniteStateMachine:
	return fsm
