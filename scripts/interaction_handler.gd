extends Node
@export var interact_layer = 0b011
@export var MouseRayCast : Node3D
@onready var Cursor = get_tree().get_first_node_in_group("cursor")
#FLAGS
var can_interact := true
var current_object
var already_interacted := false

func _process(_delta):
	interact()

func interact():
	var interaction_ray = MouseRayCast.calc_3D_interactions(interact_layer, 2)
	if interaction_ray:
		var collider = interaction_ray.collider
		if collider.is_in_group("interactable") and can_interact:
				collider.mesh.material_overlay = load("res://materials/mat_outline.tres")
				collider.mouse_interaction()
				if current_object != collider: leave_interaction() #In case we see at other collider
				current_object = collider
				already_interacted = true
		elif already_interacted:
			leave_interaction()
	elif already_interacted:
		leave_interaction()

func leave_interaction():
	if current_object != null:
		current_object.mesh.material_overlay = null
	current_object = null
	already_interacted = false
