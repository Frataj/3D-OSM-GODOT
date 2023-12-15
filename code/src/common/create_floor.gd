static func build_floor(caller_node, offset_x, offset_y):
	var floor = CSGPolygon3D.new()
	var polygonVectors = [Vector2(0,0), Vector2(0, 655.25), Vector2(655.25, 655.25), Vector2(655.25, 0)]
	floor.polygon = polygonVectors
	floor.depth = 0.1
	floor.use_collision = true
	floor.rotate(Vector3(1, 0, 0), deg_to_rad(90))
	floor.translate(Vector3(offset_x, offset_y, 1))
	caller_node.add_child(floor)
