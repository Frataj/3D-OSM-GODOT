static func calculate_polygon_vectors(sanitized_geometries):
	var size = sanitized_geometries.size()  #1
	var initial_vector = Vector2(0,0)
	var polygon_vectors = []

	for n in range(size):
		var vectors = PackedVector2Array()

		for i in range(0, sanitized_geometries[n].size() - 1, 2):
			var x = sanitized_geometries[n][i]
			var y = sanitized_geometries[n][i+1]
			initial_vector += + Vector2(x, y)
			vectors.append(initial_vector)

		polygon_vectors.append(vectors)

	return polygon_vectors
		
	
static func build_polygon_geometries(feature_geometry: Array) -> Array:
	var sanitized_geometries = []
	
	for i in range (0, feature_geometry.size(), 3):
		var current_geometry = []
		feature_geometry[i].remove_at(0)
		feature_geometry[i+1].remove_at(0)

		for coordinate in feature_geometry[i]:
			current_geometry.append(coordinate)

		for coordinate in feature_geometry[i+1]:
			current_geometry.append(coordinate)

		sanitized_geometries.append(current_geometry)
		
	return sanitized_geometries
	
