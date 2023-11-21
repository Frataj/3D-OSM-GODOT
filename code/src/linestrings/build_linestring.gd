# helper for Path3D
static func create_path3d(path, offset_x, offset_y) -> Path3D:
	var path3d = Path3D.new()
	var curve = Curve3D.new()

	for point in path:
		curve.add_point((point / 100) + Vector3(offset_x, 0, offset_y))

	path3d.curve = curve
	return path3d

# helper for CSGPolygon3D
static func create_polygon(color) -> CSGPolygon3D:
	var polygon = CSGPolygon3D.new()
	polygon.polygon = [Vector2(-1, 1), Vector2(0, 1.5), Vector2(1, 1.5), Vector2(1, 1)]
	polygon.material = create_material(color)
	polygon.mode = CSGPolygon3D.MODE_PATH
	polygon.path_interval = 0.5

	return polygon

# helper for StandardMaterial3D
static func create_material(color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	return material
	
# entry point
static func generate_paths(path_points, caller_node, color, offset_x, offset_y):
	for path in path_points:
		var path3d = create_path3d(path, offset_x, offset_y)
		caller_node.add_child(path3d)

		var polygon = create_polygon(color)
		polygon.path_node = path3d.get_path()
		caller_node.add_child(polygon)
