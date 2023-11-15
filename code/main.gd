extends Node3D

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const WEBSERVER = preload("res://src/webserver.gd")

const CALCULATE_POLYGON = preload("res://src/calculate_polygon_vectors.gd")
const CALCULATE_POLYGON_HEIGHT = preload("res://src/calculate_polygon_heights.gd")
const POINTS = preload("res://src/pois.gd")
const ROADS = preload("res://src/roads.gd")

# key represents the height
const polygon_types = {
	10: ["buildings", Color(211, 211, 211, 255)],
	0.01: ["common", Color(0, 255, 0, 255)],
#	2: ["water", Color(0, 0, 255, 255)],
}

var tiles_loaded_x_max = 1
var tiles_loaded_x_min = -1
var tiles_loaded_y_max = 1
var tiles_loaded_y_min = -1

#starting points
var x = 34373
var y = 22990

func _ready():
#loading of initial 3*3 area
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(x+i, y+j, 655.25*i, 655.25*j)

func _on_download_completed(success, current_x, current_y, offset_x, offset_y):
	if success:
		print("download successfull for: x=", current_x, ", ", current_y)
		render_geometries(current_x, current_y, offset_x, offset_y)
	else:
		print("Download failed or timed out.")

func render_geometries(x, y, offset_x, offset_y):
	var tilepath = "res://tiles/" + str(x) + str(y)
	var tile = MVT.load_tile(tilepath)

	for layer in tile.layers():
		if layer.name() == "highways":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(0,0,0,255), offset_x, offset_y)

		if layer.name() == "water":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(0,0,255,255), offset_x, offset_y)

		if layer.name() == "point":
			POINTS.generate_pois(tile, self, offset_x, offset_y)

		for height in polygon_types.keys():
			var polygon_type_data = polygon_types[height]
			if polygon_type_data[0] == layer.name():
				var polygons = CALCULATE_POLYGON.get_polygon_vectors(tile, polygon_type_data[0], offset_x, offset_y)
				var polygon_heights = CALCULATE_POLYGON_HEIGHT.get_polygon_height(tile, polygon_type_data[0])

				for i in range(polygons.size()):
					var color = polygon_type_data[1]
					add_child(CALCULATE_POLYGON.generate_polygon(polygons[i], polygon_heights[i], color, layer.name()))

func _process(delta):
	var current_location = $Player.position
	var tile_distance_x = int(current_location.x/655.25)
	var tile_distance_y = int(current_location.z/655.25)
	#load tiles if going to wards positive x loaded border
	if(tile_distance_x > (tiles_loaded_x_max - 1)):
		tiles_loaded_x_max += 1
		for i in range(tiles_loaded_y_min, tiles_loaded_y_max+1, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(x+tiles_loaded_x_max, y+i, 655.25*tiles_loaded_x_max, 655.25*i)
	#load tiles of going towards negative x border
	if(tile_distance_x < (tiles_loaded_x_min + 2)):
		tiles_loaded_x_min -= 1
		for i in range(tiles_loaded_y_min, tiles_loaded_y_max+1, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(x+tiles_loaded_x_min, y+i, 655.25*tiles_loaded_x_min, 655.25*i)
	#load tiles if going towards positive y border
	if(tile_distance_y > (tiles_loaded_y_max - 1)):
		tiles_loaded_y_max += 1
		for i in range(tiles_loaded_x_min, tiles_loaded_x_max+1, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(x+i, y+tiles_loaded_y_max, 655.25*i, 655.25*tiles_loaded_y_max)
	#load tiles if going towards negative y border
	if(tile_distance_y < (tiles_loaded_y_min + 1)):
		tiles_loaded_y_min -= 1
		for i in range(tiles_loaded_x_min, tiles_loaded_x_max+1, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(x+i, y+tiles_loaded_y_min, 655.25*i, 655.25*tiles_loaded_y_min)
