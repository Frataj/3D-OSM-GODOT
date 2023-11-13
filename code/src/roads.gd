static func build_road_geometries(feature_geometry):
	#Paths = Array of Array of Vector3s
	var paths = []
	var start_point = Vector3(0,0,0)
	var previous_point = Vector3(0,0,0)
	var last_point_of_prev_path = Vector3(0,0,0)
	#path_points = Array of Vector3s
	var path_points = []
	
	for i in range(0, feature_geometry.size(), 1):
		#if currently looked at array is for a start point,
		#clear path_points, set current_point to the start point
		#and append current point to path_points
		if feature_geometry[i][0] == 1:
			if i != 0:
				paths.append(path_points)
			path_points = []
			start_point = previous_point + Vector3(feature_geometry[i][1], 0, feature_geometry[i][2])
			previous_point = start_point
			path_points.append(start_point)
		#if cuurently looked at array is for a linestring
		#append every pair of coordinates to path_points as vector
		if feature_geometry[i][0] == 2:
			feature_geometry[i].remove_at(0)
			for n in range(0, feature_geometry[i].size()-1, 2):
				var current_point = previous_point + Vector3(feature_geometry[i][n], 0, feature_geometry[i][n+1])
				path_points.append(current_point)
				previous_point = current_point
			#if no more geometry arrays are comming after this
			#append the path_points array to paths
			if i == feature_geometry.size()-1:
				paths.append(path_points)
		#if currently looked at array defines a close shape
		#append the start point again, so the path gets closed
		#append path_points to path
		if feature_geometry[i][0] == 7:
			path_points.append(start_point)
	return paths

#for every entry, 
#make a new CSGPolygon, so we can change the path-type by tag later
#make a new Path3D with the points in the entry as points in the path
static func generate_paths(path_points, caller_node, color, offset_x, offset_y):
	for path in path_points:
		var path3d = Path3D.new()
		var curve = Curve3D.new()
		var polygon = CSGPolygon3D.new()
		for point in path:
			curve.add_point((point/100) + Vector3(offset_x, 0, offset_y))
		path3d.curve = curve
		caller_node.add_child(path3d)
		polygon.polygon = [Vector2(-1,1), Vector2(0,1.5), Vector2(1,1.5), Vector2(1,1)]
		polygon.material = StandardMaterial3D.new()
		polygon.material.albedo_color = color
		polygon.mode = CSGPolygon3D.MODE_PATH
		polygon.path_interval = 0.5
		polygon.path_node = path3d.get_path()
		caller_node.add_child(polygon)
