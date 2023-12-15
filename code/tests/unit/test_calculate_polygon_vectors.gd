extends "res://addons/gut/test.gd"

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const POLYGON_VECTOR_CALCULATOR = preload("res://src/polygons/calculate_polygon_vectors.gd")

func get_tile():
	return MVT.load_tile("res://tests/tiles/3437322991")
	
func test_get_sanitized_polygon_geometries_for_polygon():
	var tile = get_tile()
	
	var input = [[1, 54868, 19184], [2, -948, -476, 644, -1316, 980, 464], [7]]
	var expected = [[54868, 19184, -948, -476, 644, -1316, 980, 464]]
	
	var output = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(input)
	assert_eq(output, expected, "Error in sanitizing geometries for polygon")
	
func test_get_sanitized_polygon_geometries_for_multipolygon():
	var tile = get_tile()
	
	var input = [
			[1, 2368, -112], [2, -16, 1924, 292, 0, 4, -392, 5440, 32, 4, -364, -60, 0, 0, -192, -544, -4, 4, -652, -1448, -8, 4, -320], [7], 
			[1, -3728, 2636], [2, -296, -4, -8, 1588, 1732, 8, 4, -748, -1440, -12], [7], 
			[1, 1728, -5008], [2, -1016, -8, -4, 1124, 3788, 24, 0, 336, 1240, 4, 0, -164, -404, -4, 8, -1184, -3612, -24], [7]
		]
		
	var expected = [
			[2368, -112, -16, 1924, 292, 0, 4, -392, 5440, 32, 4, -364, -60, 0, 0, -192, -544, -4, 4, -652, -1448, -8, 4, -320], 
			[-3728, 2636, -296, -4, -8, 1588, 1732, 8, 4, -748, -1440, -12], 
			[1728, -5008, -1016, -8, -4, 1124, 3788, 24, 0, 336, 1240, 4, 0, -164, -404, -4, 8, -1184, -3612, -24]
		]
		
	var output = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(input)
	assert_eq(output, expected, "Error in sanitizing geometries for multipolygon")
	
func test_calculate_polygon_vectors_for_polygon():
	var tile = get_tile()
	
	var input = [[54868, 19184, -948, -476, 644, -1316, 980, 464]]
	var expected = [PackedVector2Array([
		Vector2(54868, 19184), 
		Vector2(53920, 18708), 
		Vector2(54564, 17392), 
		Vector2(55544, 17856)
	])]
	
	var output = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(input)
	assert_eq(output, expected, "Error in calculating geometries for polygon")
	
func test_calculate_polygon_vectors_for_multipolygon():
	var tile = get_tile()
	
	var input = [
			[2368, -112, -16, 1924, 292, 0, 4, -392, 5440, 32, 4, -364, -60, 0, 0, -192, -544, -4, 4, -652, -1448, -8, 4, -320], 
			[-3728, 2636, -296, -4, -8, 1588, 1732, 8, 4, -748, -1440, -12], 
			[1728, -5008, -1016, -8, -4, 1124, 3788, 24, 0, 336, 1240, 4, 0, -164, -404, -4, 8, -1184, -3612, -24]
		]
	
	var expected = [
		PackedVector2Array([
			Vector2(2368, -112), 
			Vector2(2352, 1812), 
			Vector2(2644, 1812), 
			Vector2(2648, 1420), 
			Vector2(8088, 1452), 
			Vector2(8092, 1088), 
			Vector2(8032, 1088), 
			Vector2(8032, 896), 
			Vector2(7488, 892), 
			Vector2(7492, 240), 
			Vector2(6044, 232), 
			Vector2(6048, -88)
		]), 
		PackedVector2Array([
			Vector2(2320, 2548), 
			Vector2(2024, 2544), 
			Vector2(2016, 4132), 
			Vector2(3748, 4140), 
			Vector2(3752, 3392), 
			Vector2(2312, 3380)
		]), 
		PackedVector2Array([
			Vector2(4040, -1628), 
			Vector2(3024, -1636), 
			Vector2(3020, -512), 
			Vector2(6808, -488), 
			Vector2(6808, -152), 
			Vector2(8048, -148), 
			Vector2(8048, -312), 
			Vector2(7644, -316), 
			Vector2(7652, -1500), 
			Vector2(4040, -1524)
		])
	]
	
	var output = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(input)
	assert_eq(output, expected, "Error in calculating geometries for multipolygon")

	
	
	
	
