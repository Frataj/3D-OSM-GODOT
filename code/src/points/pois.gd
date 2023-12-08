# Function to extract tree locations from the tile's layers
static func extract_tree_locations(tile, offsetx, offsety) -> Array:
	var tree_locations = []

	for layer in tile.layers():
		if layer.name() == "point":
			for feature in layer.features():
				if feature.tags(layer).type == "tree":
					tree_locations.append(
						(Vector3(feature.geometry()[0][1], 0, feature.geometry()[0][2]) / 100)
						+ Vector3(offsetx, 0, offsety)
					)

	return tree_locations

# Function to create and configure the MultiMeshInstance3D
static func create_multimesh_instance(tree_locations: Array) -> MultiMeshInstance3D:
	var multimesh_instance = MultiMesh.new()
	multimesh_instance.transform_format = 1
	multimesh_instance.instance_count = tree_locations.size()

	for i in range(tree_locations.size()):
		multimesh_instance.set_instance_transform(i, Transform3D(Basis(), tree_locations[i]))

	var tree_multimesh = MultiMeshInstance3D.new()
	tree_multimesh.set_multimesh(multimesh_instance)
	tree_multimesh.scale = Vector3(1, 1, 1)

	return tree_multimesh

# Function to load and set the mesh for the MultiMeshInstance3D
static func set_mesh_for_multimesh_instance(tree_multimesh: MultiMeshInstance3D) -> void:
	var tree_mesh = load("res://assets/GenTree_105_AE3D_03122023-F2.obj")
	tree_multimesh.multimesh.set_mesh(tree_mesh)

# Function to add the MultiMeshInstance3D to the specified node
static func add_multimesh_instance_to_node(node, tree_multimesh: MultiMeshInstance3D) -> void:
	node.add_child(tree_multimesh)

# Main function to generate POIs
static func generate_pois(tile, node, offsetx, offsety) -> void:
	var tree_locations = extract_tree_locations(tile, offsetx, offsety)
	var tree_multimesh = create_multimesh_instance(tree_locations)
	set_mesh_for_multimesh_instance(tree_multimesh)
	add_multimesh_instance_to_node(node, tree_multimesh)
