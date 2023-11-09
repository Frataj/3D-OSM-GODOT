extends "res://addons/gut/test.gd"

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const CALCULATE_POLYGON = preload("res://src/calculate_polygon_vectors.gd")

const LAYERS = []

func get_tile():
	return MVT.load_tile("res://tests/tiles/3437322991")
	

	

