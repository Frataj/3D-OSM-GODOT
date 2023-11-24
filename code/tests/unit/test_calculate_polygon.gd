extends "res://addons/gut/test.gd"

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const CALCULATE_POLYGON = preload("res://src/polygons/calculate_polygon_vectors.gd")
const TYPE = "buildings"

func get_tile():
	return MVT.load_tile("res://tests/tiles/3437322991")
	
func test_get_sanitized_polygon_geometries():
	var tile = get_tile()
	
	var input = [
			[[1, -528, 8672], [2, 1232, 1492], [7]], 
			[[1, 9228, -7488], [2, 264, -212], [7]],
			[[1, 68232, -1996], [2, 348, -516, 972, 664, -348, 516], [7]]
		]
		
	var expected_output = [
			[-528, 8672, 1232, 1492], 
			[9228, -7488, 264, -212],
			[68232, -1996, 348, -516, 972, 664, -348, 516],
		]
		
	var output = CALCULATE_POLYGON.get_sanitized_polygon_geometries(input)
	assert(output.size() != expected_output.size() * 2, "Size mismatch in output array")
	assert_eq(output, expected_output, "Error in sanitizing geometries")
	
	
func test_calculate_polygon_vectors():
	var tile = get_tile()

	var input = [
		[-528, 8672, 1232, 1492], 
		[9228, -7488, 264, -212],
		[68232, -1996, 348, -516, 972, 664, -348, 516],
	]

	var expected_output = [
		[Vector2(-5.28, 86.72), Vector2(7.04, 101.64)], 
		[Vector2(92.28, -74.88), Vector2(94.92, -77)], 
		[Vector2(682.32, -19.96), Vector2(685.8, -25.12), Vector2(695.52, -18.48), Vector2(692.04, -13.32)],
	]

	var output = CALCULATE_POLYGON.calculate_polygon_vectors(input, 0, 0)
	
	for i in range(output.size()):
		for j in range(output[i].size()):
			assert_eq(output[i][j], expected_output[i][j], "Error in calculating vectors")



	
