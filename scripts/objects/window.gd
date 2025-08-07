class_name window
extends Shootable

func _on_shoot(direction : Vector3, position : Vector3):
	print("being shooted")
	var static_window : MeshInstance3D = get_parent()
	var fractured_double : VoronoiCollection = static_window.get_child(0)
	var window_fragments = fractured_double.get_children()
	
	collision_layer = 0b00
	static_window.mesh = null
	fractured_double.visible = true
	for fragment in window_fragments:
		if fragment is RigidBody3D:
			fragment.freeze = false
			#fragment.apply_force(direction * 3)
	
	var delete_timer : Timer = Timer.new()
	delete_timer.one_shot = true
	add_child(delete_timer)
	delete_timer.start(4)
	delete_timer.timeout.connect(func(): static_window.queue_free())
	
