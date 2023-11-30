const CREATE_CSGPOLYGON3D = preload("res://src/common/create_csgpolygon3d.gd")

static func generate_polygons(vectors, caller_node, color, offset_x, offset_y, heights = null):
	for i in range(vectors.size()):
		var vactors_with_offset = []
		for vector in vectors[i]:
			vactors_with_offset.append((vector / 100) + Vector2(offset_x, offset_y))
		var height = 0.001 if not heights else heights[i]
		var polygon = CREATE_CSGPOLYGON3D.create_polygon(color, vactors_with_offset)
		polygon.depth = height
		polygon.use_collision = true
		polygon.rotate(Vector3(1, 0, 0), deg_to_rad(90))
		caller_node.add_child(polygon)
