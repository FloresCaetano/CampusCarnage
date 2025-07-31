@tool
extends Node3D

func _ready():
	var grid_map: GridMap = $GridMap
	var mesh_library = grid_map.mesh_library
	if mesh_library == null:
		push_error("El GridMap no tiene una MeshLibrary.")
		return
	
	var result_mesh = ArrayMesh.new()
	var arrays_all = {}
	arrays_all[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays_all[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	arrays_all[Mesh.ARRAY_INDEX] = PackedInt32Array()

	var vertex_offset = 0

	for cell in grid_map.get_used_cells():
		var item = grid_map.get_cell_item(cell)
		var mesh = mesh_library.get_item_mesh(item)
		if mesh == null:
			continue
		
		var transform = grid_map.map_to_local(cell)
		for surface in range(mesh.get_surface_count()):
			var arrays = mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]

			var transformed_vertices = PackedVector3Array()
			var transformed_normals = PackedVector3Array()

			for v in vertices:
				transformed_vertices.append(transform * v)
			for n in normals:
				transformed_normals.append(transform.basis * n)

			for i in indices:
				arrays_all[Mesh.ARRAY_INDEX].append(i + vertex_offset)

			arrays_all[Mesh.ARRAY_VERTEX].append_array(transformed_vertices)
			arrays_all[Mesh.ARRAY_NORMAL].append_array(transformed_normals)

			vertex_offset += transformed_vertices.size()
	
	var final_arrays = []
	final_arrays.resize(Mesh.ARRAY_MAX)
	final_arrays[Mesh.ARRAY_VERTEX] = arrays_all[Mesh.ARRAY_VERTEX]
	final_arrays[Mesh.ARRAY_NORMAL] = arrays_all[Mesh.ARRAY_NORMAL]
	final_arrays[Mesh.ARRAY_INDEX] = arrays_all[Mesh.ARRAY_INDEX]

	result_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, final_arrays)

	# Guardar como recurso
	var save_path = "res://exported_gridmap_mesh.mesh"
	var error = ResourceSaver.save(save_path, result_mesh)
	if error == OK:
		print("✅ Malla exportada en:", save_path)
	else:
		push_error("❌ Error al guardar la malla.")
