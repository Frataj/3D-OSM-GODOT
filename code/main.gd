extends Node3D
#@tool
#extends EditorScript

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const CALCULATE_POLYGON = preload("res://src/calculate_polygon_vectors.gd")
const ROADS = preload("res://src/roads.gd")

# key represents the height
const polygon_types = {
	10: ["buildings", Color(211, 211, 211, 255)],
	0.001: ["common", Color(0, 255, 0, 255)],
#	2: ["water", Color(0, 0, 255, 255)],
}

func _ready():
	var start_x = 34316
	var start_y = 22954

	var tile_http_link = "https://tiles.streets.gl/vector/16/" + str(start_x) + "/" + str(start_y)
	var downloaded_tile = "res://tiles/" + str(start_x) + str(start_y)
	$HTTPRequest.download_file = downloaded_tile
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request(tile_http_link)

func _on_request_completed(result, response_code, headers, body):
	var tile = MVT.load_tile($HTTPRequest.download_file)
	var tile2 = MVT.load_tile("res://tiles/3431622953")
		
	for height in polygon_types.keys():
		var polygon_type_data = polygon_types[height]
		var polygons = CALCULATE_POLYGON.get_polygon_vectors(tile, polygon_type_data[0], 0, 0)
		for polygon in polygons:
			var color = polygon_type_data[1]
			add_child(CALCULATE_POLYGON.generate_polygon(polygon, height, color))
		var polygons2 = CALCULATE_POLYGON.get_polygon_vectors(tile2, polygon_type_data[0], 0, -655.25)
		for polygon2 in polygons2:
			var color = polygon_type_data[1]
			add_child(CALCULATE_POLYGON.generate_polygon(polygon2, height, color))

	for layer in tile.layers():
		if layer.name() == "highways":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(0,0,0,255), 0, 0)
		if layer.name() == "water":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(0,0,255,255), 0, 0)
		
	for layer in tile2.layers():
		if layer.name() == "highways":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(155,0,0,255), 0, -655.25)
		if layer.name() == "water":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(255,0,0,255), 0, -655.25)

func _process(delta):
	pass
