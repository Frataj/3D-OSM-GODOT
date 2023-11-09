extends "res://addons/gut/test.gd"

func test_equality():
	var variable = "apples";
	assert_eq(variable, "apples", "Should've been apples")
