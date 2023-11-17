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

var tiles_loaded_x_max = 2
var tiles_loaded_x_min = -2
var tiles_loaded_y_max = 2
var tiles_loaded_y_min = -2

#starting points
const x = 34312
const y = 22947

#updated process points
var process_x = null
var process_y = null

func _ready():
#loading of initial 3*3 area
	for i in range(-2, 2, 1):
		for j in range(-2, 2, 1):
			var tile_node = Node3D.new()
			tile_node.name = str(x + i) + str(y + j)
			var webserver = WEBSERVER.new()
			add_child(tile_node)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			process_x = x + i
			process_y = y + j
			webserver.downloadFile(process_x, process_y, 655.25*i, 655.25*j)
	process_x = x
	process_y = y

func _on_download_completed(success, current_x, current_y, offset_x, offset_y):
	if success:
		print("download successfull for: x=", current_x, ", ", current_y)
		render_geometries(current_x, current_y, offset_x, offset_y)
	else:
		print("Download failed or timed out.")


func render_geometries(x, y, offset_x, offset_y):
	var tilepath = "res://tiles/" + str(x) + str(y)
	var tile = MVT.load_tile(tilepath)
	
	var current_tile_node_path = str(x) + str(y)
	print(current_tile_node_path)
	var tile_current = get_node(current_tile_node_path)
	
	print("expected: " + tile_current.name)
	for layer in tile.layers():
		if layer.name() == "highways":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), tile_current, Color(0,0,0,255), offset_x, offset_y)

		if layer.name() == "water":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), tile_current, Color(0,0,255,255), offset_x, offset_y)

		if layer.name() == "point":
			pass
			#POINTS.generate_pois(tile, tile_current, offset_x, offset_y)

		for height in polygon_types.keys():
			var polygon_type_data = polygon_types[height]
			if polygon_type_data[0] == layer.name():
				var polygons = CALCULATE_POLYGON.get_polygon_vectors(tile, polygon_type_data[0], offset_x, offset_y)
				var polygon_heights = CALCULATE_POLYGON_HEIGHT.get_polygon_height(tile, polygon_type_data[0])

				for i in range(polygons.size()):
					var color = polygon_type_data[1]
					tile_current.add_child(CALCULATE_POLYGON.generate_polygon(polygons[i], polygon_heights[i], color, layer.name()))

func _process(delta):
	var current_location = $Player.position
	var tile_distance_x = int(current_location.x/655.25)
	var tile_distance_y = int(current_location.z/655.25)
	
	#load tiles if going to wards positive x loaded border
	if(tile_distance_x > (tiles_loaded_x_max - 2)):
		tiles_loaded_x_max += 1
		process_x = process_x + 2
		for i in range(tiles_loaded_y_min, tiles_loaded_y_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x) + str(process_y + i)
			print(tile_node.name + "loading")
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(process_x, process_y+i, 655.25*(tiles_loaded_x_max - 1), 655.25*i)
		tiles_loaded_x_min += 1
		
	#load tiles of going towards negative x border
	if(tile_distance_x < (tiles_loaded_x_min + 2)):
		tiles_loaded_x_min -= 1
		process_x = process_x - 3
		for i in range(tiles_loaded_y_min, tiles_loaded_y_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x) + str(process_y + i)
			print(tile_node.name + "loading")
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(process_x, process_y + i, 655.25*(tiles_loaded_x_min), 655.25*i)
		tiles_loaded_x_max -= 1
	
	#load tiles if going towards positive y border
	if(tile_distance_y > (tiles_loaded_y_max - 2)):
		tiles_loaded_y_max += 1
		process_y = process_y + 2
		for i in range(tiles_loaded_x_min, tiles_loaded_x_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x + i) + str(process_y)
			print(tile_node.name + "loading")
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(process_x + i, process_y, 655.25*i, 655.25*(tiles_loaded_y_max - 1))
		tiles_loaded_y_min += 1
	
	#load tiles if going towards negative y border
	if(tile_distance_y < (tiles_loaded_y_min + 2)):
		tiles_loaded_y_min -= 1
		process_y = process_y - 3
		for i in range(tiles_loaded_x_min, tiles_loaded_x_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x + i) + str(process_y)
			print(tile_node.name + "loading")
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.downloadFile(process_x + i, process_y, 655.25*i, 655.25*tiles_loaded_y_min)
		tiles_loaded_y_max -= 1
