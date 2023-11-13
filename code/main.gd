extends Node3D

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const CALCULATE_POLYGON = preload("res://src/calculate_polygon_vectors.gd")
const ROADS = preload("res://src/roads.gd")
const WEBSERVER = preload("res://src/webserver.gd")

# key represents the height
const polygon_types = {
	10: ["buildings", Color(211, 211, 211, 255)],
	0.001: ["common", Color(0, 255, 0, 255)],
#	2: ["water", Color(0, 0, 255, 255)],
}

var x = null;
var y = null;
var current_tile_path = ""
var webserver = WEBSERVER.new()

func set_x(value):
	x = value
	
func set_y(value):
	y = value

func set_current_tile_path(path):
	current_tile_path = path

func _ready():
	add_child(webserver)
	webserver.connect("download_completed", _on_download_completed)
	
	set_x(34317)
	set_y(22953)
	
	set_current_tile_path("res://tiles/" + str(x) + str(y))
	webserver.downloadFile(x, y)

func _on_download_completed(success):
	if success:
		render_geometries()
	else:
		print("Download failed or timed out.")
		
func render_geometries():	
	var tile = MVT.load_tile(current_tile_path)
	
	for height in polygon_types.keys():
		var polygon_type_data = polygon_types[height]
		var polygons = CALCULATE_POLYGON.get_polygon_vectors(tile, polygon_type_data[0], 0, 0)
		for polygon in polygons:
			var color = polygon_type_data[1]
			add_child(CALCULATE_POLYGON.generate_polygon(polygon, height, color))

	for layer in tile.layers():
		if layer.name() == "highways":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(0,0,0,255), 0, 0)
		if layer.name() == "water":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self, Color(0,0,255,255), 0, 0)

func _process(delta):
	var current_location = $Player.position
	var distance = Vector3(0,0,0) - current_location
	if distance.x > 20:
	print("(", distance.x, ", ", distance.z, ")")
