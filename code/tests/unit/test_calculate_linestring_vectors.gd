extends "res://addons/gut/test.gd"

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const LINESTRING_VECTOR_CALCULATOR = preload("res://src/linestrings/calculate_linestring_vectors.gd")

func get_tile():
	return MVT.load_tile("res://tests/tiles/3437322991")
	
func test_build_linestring_geometries_for_linestring():
	var input = [
			[1, 21231, -6144], [2, 14597, 5928, 912, 372, 1040, 424]
		]
		
	var expected = [
			[
				Vector3(21231, 0, -6144), 
				Vector3(35828, 0, -216), 
				Vector3(36740, 0, 156), 
				Vector3(37780, 0, 580)
			]
		]
	
	var output = LINESTRING_VECTOR_CALCULATOR.build_linestring_geometries(input)
	
	assert_eq(output, expected, "Error in calculating geometries for multipolygon")

func test_build_linestring_geometries_for_multilinestring():
	var input = [
			[1, 57192, 46276], [2, 460, 464, 10488, 12056, 3540, 4069], 
			[1, -38222, 8815], [2, -78, -116]
		]
	
	var expected = [
			[
				Vector3(57192, 0, 46276), 
				Vector3(57652, 0, 46740), 
				Vector3(68140, 0, 58796), 
				Vector3(71680, 0, 62865)
			], 
			[
				Vector3(18970, 0, 55091), 
				Vector3(18892, 0, 54975)
			]
		]
		
	var output = LINESTRING_VECTOR_CALCULATOR.build_linestring_geometries(input)
		
	assert_eq(output, expected, "Error in calculating geometries for multipolygon")
