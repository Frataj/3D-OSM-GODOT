# helper for start points
static func handle_start_point(
	path_points: Array, previous_point: Vector3, x_offset: float, z_offset: float
) -> Vector3:
	var start_point = previous_point + Vector3(x_offset, 0, z_offset)
	path_points.append(start_point)
	return start_point


# helper for line strings
static func handle_line_string(
	path_points: Array, previous_point: Vector3, coordinates: Array
) -> Array:
	for n in range(0, coordinates.size() - 1, 2):
		var current_point = previous_point + Vector3(coordinates[n], 0, coordinates[n + 1])
		path_points.append(current_point)
		previous_point = current_point
	return path_points


# close shapes
static func handle_close_shape(path_points: Array, start_point: Vector3) -> void:
	path_points.append(start_point)


# entry point
static func build_linestring_geometries(feature_geometry: Array) -> Array:
	var paths = []
	var path_points = []
	var previous_point = Vector3(0, 0, 0)

	for i in range(0, feature_geometry.size(), 1):
		if feature_geometry[i][0] == 1:
			if i != 0:
				paths.append(path_points)
			path_points = []
			previous_point = handle_start_point(
				path_points, previous_point, feature_geometry[i][1], feature_geometry[i][2]
			)
		elif feature_geometry[i][0] == 2:
			feature_geometry[i].remove_at(0)
			path_points = handle_line_string(path_points, previous_point, feature_geometry[i])
			if i == feature_geometry.size() - 1:
				paths.append(path_points)
		elif feature_geometry[i][0] == 7:
			handle_close_shape(path_points, path_points[0])

	return paths
