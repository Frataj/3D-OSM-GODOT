@tool
extends EditorScript

const LINESTRING_VECTOR_CALCULATOR = preload("res://src/linestrings/calculate_linestring_vectors.gd")

func _run():
	var input = [
			[1, 57192, 46276], [2, 460, 464, 10488, 12056, 3540, 4069], 
			[1, -38222, 8815], [2, -78, -116]
		]
		
	var expected = [
			[
				Vector3(21231, 0, -6144), 
				Vector3(35828, 0, -216), 
				Vector3(36740, 0, 156), 
				Vector3(37780, 0, 580)
			]
		]
		
	var path_points = []
	var geo1 = 58068
	var geo2 = 2440
	
	var output = LINESTRING_VECTOR_CALCULATOR.(input)
	
	print(input)
	print(output)
