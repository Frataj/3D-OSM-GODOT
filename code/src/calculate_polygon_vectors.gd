static func generate_polygon(vectors):
	var polygon = CSGPolygon3D.new()
	polygon.depth = 2.5
	polygon.polygon = vectors
	polygon.use_collision = true
	polygon.rotate(Vector3(1,0,0), deg_to_rad(90))
	print("hello from generate_polygon")
	return polygon

static func calculate_polygon_vectors(sanitized_geometries):
	var size = sanitized_geometries.size()
	var polygon_vectors = []

	for n in range(size):
		var initial_vector = Vector2(0,0)
		var vectors = PackedVector2Array()

		for i in range(0, sanitized_geometries[n].size() - 1, 2):
			var x = sanitized_geometries[n][i]
			var y = sanitized_geometries[n][i+1]

			initial_vector += + Vector2(x, y)
			vectors.append(initial_vector / 100)

		polygon_vectors.append(vectors)

	return polygon_vectors
	
	
static func get_sanitized_polygon_geometries(geometries):
	var sanitized_geometries = []
	
	for i in range(geometries.size()):
		var current_geometry = []
		#removing instruction codes
		geometries[i][0].remove_at(0)
		geometries[i][1].remove_at(0)
		geometries[i].remove_at(2)
		#combine the subarrays into one
		for coordinate in geometries[i][0]:
			current_geometry.append(coordinate)
		for coordinate in geometries[i][1]:
			current_geometry.append(coordinate)
		sanitized_geometries.append(current_geometry)
		
	return sanitized_geometries


static func get_polygon_geometries(polygons):
	var polygon_geometries = []

	for n in range(polygons.size()):
		polygon_geometries.append(polygons[n].geometry())

	return polygon_geometries


static func get_polygon_features(tile):
	var polygons
	var layers = tile.layers()
	for i in layers.size():
		if layers[i].name() == "building":
			polygons = layers[i]
	return polygons.features()


static func get_polygon_vectors(tile):
	var polygon = get_polygon_features(tile)
	var geometries = get_polygon_geometries(polygon)
	var sanitized_geometries = get_sanitized_polygon_geometries(geometries)
	return calculate_polygon_vectors(sanitized_geometries)
