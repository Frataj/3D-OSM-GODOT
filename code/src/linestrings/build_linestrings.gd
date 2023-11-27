const CREATE_CSGPOLYGON3D = preload("res://src/common/create_csgpolygon3d.gd")

# helper for Path3D
static func create_path3d(path, offset_x, offset_y) -> Path3D:
	var path3d = Path3D.new()
	var curve = Curve3D.new()

	for point in path:
		curve.add_point((point / 100) + Vector3(offset_x, 0, offset_y))

	path3d.curve = curve
	return path3d
	
# entry point
static func generate_paths(path_points, caller_node, color, offset_x, offset_y):
	var path_polygon = [Vector2(-1, 1), Vector2(0, 1.5), Vector2(1, 1.5), Vector2(1, 1)]

	for path in path_points:
		var path3d = create_path3d(path, offset_x, offset_y)
		caller_node.add_child(path3d)

		var polygon = CREATE_CSGPOLYGON3D.create_polygon(color, path_polygon)
		polygon.mode = CSGPolygon3D.MODE_PATH
		polygon.path_interval = 0.5
		polygon.path_node = path3d.get_path()
		caller_node.add_child(polygon)
