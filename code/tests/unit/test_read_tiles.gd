extends "res://addons/gut/test.gd"

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")

const LAYERS = []

func get_tile():
	return MVT.load_tile("res://tests/tiles/3437322991")


func test_read_layer():
	var tile = get_tile()
	assert_not_null(tile, "Failed to load the tile")
	assert(tile.layers().size() > 0, "No layers found in the tile")
	
	var layer = tile.layers()[0]
	assert_not_null(layer, "Failed to get the layer")
	
	var layer_name = tile.layers()[0].name()
	assert(layer_name != "", "Layer name is empty")
	
	
