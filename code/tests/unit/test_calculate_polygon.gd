extends "res://addons/gut/test.gd"

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const CALCULATE_POLYGON = preload("res://src/calculate_polygon_vectors.gd")
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
			[68232, -1996, 348, -516, 972, 664, -348, 516]
		]
		
	var output = CALCULATE_POLYGON.get_sanitized_polygon_geometries(input)	
	assert_eq(output, expected_output, "Error in sanitizing geometries")
	
