extends Node3D

@export var GunScene : PackedScene
@onready var camera : Camera3D = get_tree().get_first_node_in_group("Camera")
var Gun
var tween2 : Tween

func _ready() -> void:
	Gun = GunScene.instantiate()
	add_child(Gun)
	Gun.position = Gun.gun_displacement

func calc_3D_interactions(mask, lenght):
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = camera.project_position(mouse_pos, lenght)
	var ray_params = PhysicsRayQueryParameters3D.create(origin, end)
	ray_params.collide_with_areas = true
	ray_params.collide_with_bodies = true
	ray_params.collision_mask = mask
	ray_params.hit_back_faces = false
	ray_params.hit_from_inside = false
	var ray = get_world_3d().direct_space_state.intersect_ray(ray_params)
	
	return [ray, (end - origin).normalized()]

func shoot_anim_start():
	Gun.play_anim("shot")


func shot():
	#ANIMATION
	shoot_anim_start()
	var shoot_ray = calc_3D_interactions(0b1000, 100)
	if not shoot_ray[0]:
		return
	
	var collider = shoot_ray[0].collider
	var normal = shoot_ray[0].normal
	var ray_position = shoot_ray[0].position
	var ray_direction = shoot_ray[1]
	
	if collider is RigidBody3D:
		collider.apply_force(ray_direction * Gun.push, ray_position - collider.global_position)
	if collider is Enemy:
		var enemy_fsm : FiniteStateMachine = collider.get_fsm()
		enemy_fsm.change_state(collider.enemy_death_state)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		shot()
