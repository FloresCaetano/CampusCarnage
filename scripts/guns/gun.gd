extends Node3D

@export var gun_displacement : Vector3 = Vector3.ZERO
@export var damage : float = 1.0
@export var push : float = 100.0
@export var animation_player : AnimationPlayer

func play_anim(anim : String):
	animation_player.play(anim)
