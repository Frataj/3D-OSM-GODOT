extends "res://addons/gut/test.gd"

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")

func get_tile():
	return MVT.load_tile("res://tests/tiles/3437322991")


func test_read_layer():
	var tile = get_tile()
	var layer_name = tile.layers()[0].name()
	assert_eq(layer_name, "point", "Should have been point")
