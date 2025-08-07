@tool

extends MeshInstance3D

@export var group : String = "destructible"
@export_tool_button("Generate Fractured", "MeshInstance3D") 
var execute_action = generate_fractured
@export_tool_button("Set Freeze On RG", "RigidBody3D") 
var set_freeze_call = _set_freeze_on_fragments

func generate_fractured():
	var voronoi_shatter : VoronoiShatter = VoronoiShatter.new() #: VoronoiShatter = VoronoiShatter.new()
	voronoi_shatter.name = "f_window" + "_" + str(Time.get_ticks_msec())
	voronoi_shatter.random_color = false
	voronoi_shatter.inherit_outer_material = true
	
	add_sibling(voronoi_shatter)
	voronoi_shatter.set_owner(owner)
	
	var temp_mesh = self.duplicate()
	temp_mesh.scale = Vector3(1, 1, 1)
	voronoi_shatter.add_child(temp_mesh)
	temp_mesh.set_owner(owner)
	temp_mesh.name = self.name
	voronoi_shatter.execute()
	await configure_fractured_double(voronoi_shatter)
	voronoi_shatter.call_deferred("queue_free")
	
	if group != "":
		add_to_group(group)

func configure_fractured_double(vs : VoronoiShatter):
	while vs.get_child_count() < 2:
		await get_tree().process_frame
	
	var fractured_double : VoronoiCollection = vs.get_child(1)
	fractured_double.call_deferred("create_rigid_bodies")
	fractured_double.global_transform = self.global_transform
	fractured_double.reparent(self, true)
	fractured_double.visible = false

func _set_freeze_on_fragments():
	for fragment in get_child(0).get_children():
		if fragment is RigidBody3D: fragment.freeze = true
