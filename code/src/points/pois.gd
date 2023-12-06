#right now only does trees, can be adapted for other pois
static func generate_pois(tile, node, offsetx, offsety):
	var tree_locations = []
	for layer in tile.layers():
		if layer.name() == "point":
			for feature in layer.features():
				if feature.tags(layer).type == "tree":
					tree_locations.append(
						(
							(Vector3(feature.geometry()[0][1], 0, feature.geometry()[0][2]) / 100)
							+ Vector3(offsetx, 0, offsety)
						)
					)
	var tree_multimesh = MultiMeshInstance3D.new()
	var multimesh_instance = MultiMesh.new()
	multimesh_instance.transform_format = 1
	multimesh_instance.instance_count = tree_locations.size()
	for i in range(tree_locations.size()):
		multimesh_instance.set_instance_transform(i, Transform3D(Basis(), tree_locations[i]))
	var tree_mesh = load("res://assets/GenTree_105_AE3D_03122023-F2.obj")
	multimesh_instance.set_mesh(tree_mesh)
	tree_multimesh.set_multimesh(multimesh_instance)
	tree_multimesh.scale = Vector3(1, 1, 1)
	node.add_child(tree_multimesh)
