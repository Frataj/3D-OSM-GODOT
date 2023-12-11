# Function to extract POI locations from the tile's layers
static func extract_poi_locations(feature, offsetx, offsety) -> Array:
	var poi_locations = []
	poi_locations.append(
		(Vector3(feature.geometry()[0][1], 0, feature.geometry()[0][2]) / 100)
		+ Vector3(offsetx, 0, offsety)
		)
	return poi_locations

# Function to create and configure the MultiMeshInstance3D
static func create_multimesh_instance(poi_locations: Array) -> MultiMeshInstance3D:
	var multimesh_instance = MultiMesh.new()
	multimesh_instance.transform_format = 1
	multimesh_instance.instance_count = poi_locations.size()

	for i in range(poi_locations.size()):
		multimesh_instance.set_instance_transform(i, Transform3D(Basis(), poi_locations[i]))

	var poi_multimesh = MultiMeshInstance3D.new()
	poi_multimesh.set_multimesh(multimesh_instance)
	poi_multimesh.scale = Vector3(1, 1, 1)

	return poi_multimesh

# Function to load and set the mesh for the MultiMeshInstance3D
static func set_mesh_for_multimesh_instance(poi_multimesh: MultiMeshInstance3D, tag) -> void:
	if tag == "tree":
		var tree_mesh = load("res://assets/Tree lowpoly.obj")
		poi_multimesh.multimesh.set_mesh(tree_mesh)
	if tag == "bench":
		var bench_mesh = load("res://assets/Wooden Bench Weathered 2.obj")
		poi_multimesh.multimesh.set_mesh(bench_mesh)

# Function to add the MultiMeshInstance3D to the specified node
static func add_multimesh_instance_to_node(node, poi_multimesh: MultiMeshInstance3D) -> void:
	node.add_child(poi_multimesh)

# Main function to generate POIs
static func generate_pois(tile, node, offsetx, offsety) -> void:
	for layer in tile.layers():
		if layer.name() == "point":
			for feature in layer.features():
				if feature.tags(layer).type == "tree":
					var tree_locations = extract_poi_locations(feature, offsetx, offsety)
					var tree_multimesh = create_multimesh_instance(tree_locations)
					set_mesh_for_multimesh_instance(tree_multimesh, feature.tags(layer).type)
					add_multimesh_instance_to_node(node, tree_multimesh)
				if feature.tags(layer).type == "bench":
					var bench_locations = extract_poi_locations(feature, offsetx, offsety)
					var bench_multimesh = create_multimesh_instance(bench_locations)
					set_mesh_for_multimesh_instance(bench_multimesh, feature.tags(layer).type)
					add_multimesh_instance_to_node(node, bench_multimesh)
