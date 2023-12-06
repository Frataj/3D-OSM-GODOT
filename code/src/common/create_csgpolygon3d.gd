#helper for CSGPolygon3D
static func create_polygon(color, vector) -> CSGPolygon3D:
	var polygon = CSGPolygon3D.new()
	polygon.polygon = vector
	polygon.material = create_material(color)
	return polygon


#helper for StandardMaterial3D
static func create_material(color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	return material
