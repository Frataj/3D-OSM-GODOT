extends Node3D

const MVT_READER = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const WEBSERVER = preload("res://src/webserver.gd")

const CALCULATE_LINESTRING_VECTORS = preload(
	"res://src/linestrings/calculate_linestring_vectors.gd"
)
const BUILD_LINESTRINGS = preload("res://src/linestrings/build_linestrings.gd")

const CALCULATE_POLYGON_VECTORS = preload("res://src/polygons/calculate_polygon_vectors.gd")
const CALCULATE_POLYGON_HEIGHT = preload("res://src/polygons/calculate_polygon_heights.gd")
const BUILD_POLYGONS = preload("res://src/polygons/build_polygons.gd")

const POINTS = preload("res://src/points/pois.gd")

const BUILDINGS = "buildings"
const COMMON = "common"
const HIGHWAYS = "highways"
const WATER = "water"
const POINT = "point"
const NATURAL = "natural"

#starting points rapperswil jona
#const x = 34373
#const y = 22990

const START_X = 34318
const START_Y = 22952

const TYPE_COLOR = {
	BUILDINGS: Color(0.5, 0.5, 0.5, 1.0),
	COMMON: Color(0.133, 0.545, 0.133, 1.0),
	HIGHWAYS: Color(0, 0, 0, 1),
	WATER: Color(0.004, 0.34, 0.61, 0.4),
	NATURAL: Color(0.21, 0.42, 0.21, 1),
}

const ROAD_WIDTHS = {
	"motorway": 15,
	"primary": 5.5,
	"secondary": 5,
	"tertiary": 4.5,
	"residential": 4.5,
}

var tiles_loaded_x_max = 2
var tiles_loaded_x_min = -2
var tiles_loaded_y_max = 2
var tiles_loaded_y_min = -2

#updated process points
var process_x = null
var process_y = null

var steps_x = 0
var steps_y = 0

func _ready():
#loading of initial 4*4 area
	for i in range(-2, 2, 1):
		for j in range(-2, 2, 1):
			var tile_node = Node3D.new()
			tile_node.name = str(START_X + i) + str(START_Y + j)
			add_child(tile_node)
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			process_x = START_X + i
			process_y = START_Y + j
			webserver.download_file(process_x, process_y, 655.25 * i, 655.25 * j)
	process_x = START_X
	process_y = START_Y
#	var tile = MVT_READER.load_tile("res://tiles/" + str(START_X) + str(START_Y))
#	for layer in tile.layers():
#		print(layer.name())


func _on_download_completed(success, current_x, current_y, offset_x, offset_y):
	if success:
		print("download successfull for: x=", current_x, ", ", current_y)
		render_geometries(current_x, current_y, offset_x, offset_y)
	else:
		print("Download failed or timed out.")


func render_geometries(x, y, offset_x, offset_y):
	var tilepath = "res://tiles/" + str(x) + str(y)
	var tile = MVT_READER.load_tile(tilepath)

	var current_tile_node_path = str(x) + str(y)
	var tile_node_current = get_node(current_tile_node_path)
	
	var floor = CSGPolygon3D.new()
	var polygonVectors = [Vector2(0,0), Vector2(0, 655.25), Vector2(655.25, 655.25), Vector2(655.25, 0)]
	floor.polygon = polygonVectors
	floor.rotate(Vector3(1, 0, 0), deg_to_rad(90))
	floor.translate(Vector3(offset_x, offset_y, 2))
	tile_node_current.add_child(floor)

	for layer in tile.layers():
		if layer.name() == HIGHWAYS:
			for feature in layer.features():
				var width = null
				if feature.tags(layer).has("pathType"):
					if ROAD_WIDTHS.has(feature.tags(layer).pathType):
						width = ROAD_WIDTHS[feature.tags(layer).pathType]
				var linestring_geometries = (
					CALCULATE_LINESTRING_VECTORS.build_linestring_geometries(feature.geometry())
				)
				BUILD_LINESTRINGS.generate_paths(
					linestring_geometries,
					tile_node_current,
					TYPE_COLOR[layer.name()],
					offset_x,
					offset_y,
					width
				)

		if layer.name() == BUILDINGS:
			for feature in layer.features():
				var polygon_height = CALCULATE_POLYGON_HEIGHT.get_polygon_height(
					feature, layer
				)
				var polygon_geometries = CALCULATE_POLYGON_VECTORS.build_polygon_geometries(
					feature.geometry()
				)
				BUILD_POLYGONS.generate_polygons(
					polygon_geometries,
					tile_node_current,
					TYPE_COLOR[layer.name()],
					offset_x,
					offset_y,
					polygon_height
				)

		if layer.name() == COMMON:
			for feature in layer.features():
				var polygon_geometries = CALCULATE_POLYGON_VECTORS.build_polygon_geometries(
					feature.geometry()
				)
				BUILD_POLYGONS.generate_polygons(
					polygon_geometries,
					tile_node_current,
					TYPE_COLOR[layer.name()],
					offset_x,
					offset_y,
					0.5
				)

		if layer.name() == WATER:
			for feature in layer.features():
				var type = feature.geom_type()
				if type["GeomType"] == "LINESTRING":
					var linestring_geometries = (
						CALCULATE_LINESTRING_VECTORS.build_linestring_geometries(feature.geometry())
					)
					BUILD_LINESTRINGS.generate_paths(
						linestring_geometries,
						tile_node_current,
						TYPE_COLOR[layer.name()],
						offset_x,
						offset_y
					)
				if type["GeomType"] == "POLYGON":
					var polygon_geometries = CALCULATE_POLYGON_VECTORS.build_polygon_geometries(
						feature.geometry()
					)
					BUILD_POLYGONS.generate_polygons(
						polygon_geometries,
						tile_node_current,
						TYPE_COLOR[layer.name()],
						offset_x,
						offset_y
					)

		if layer.name() == POINT:
			pass
			#POINTS.generate_pois(tile, tile_current, offset_x, offset_y)
		
		if layer.name() == NATURAL:
			for feature in layer.features():
				var polygon_geometries = CALCULATE_POLYGON_VECTORS.build_polygon_geometries(
					feature.geometry()
				)
				BUILD_POLYGONS.generate_polygons(
					polygon_geometries,
					tile_node_current,
					TYPE_COLOR[layer.name()],
					offset_x,
					offset_y,
					0.5
				)

# _process needs an argument, even if its never used
# gdlint:ignore = unused-argument
func _process(delta):
	var tile_distance_x = int($Player.position.x / 655.25)
	var tile_distance_y = int($Player.position.z / 655.25)

	var a = -2
	var b = 2

	#load tiles if going to wards positive x loaded border
	if tile_distance_x > (tiles_loaded_x_max - 2):
		tiles_loaded_x_max += 1
		tiles_loaded_x_min += 1
		process_x = process_x + 2

		steps_x += 1

		for i in range(a, b, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x) + str(process_y + i)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x, process_y + i, 655.25 * (tiles_loaded_x_max - 1), 655.25 * (i + steps_y)
			)

			var childnode = get_node(str(process_x - 4) + str(process_y + i))
			remove_child(childnode)

		process_x = process_x - 1

	#load tiles of going towards negative x border
	if tile_distance_x < (tiles_loaded_x_min + 2):
		tiles_loaded_x_max -= 1
		tiles_loaded_x_min -= 1
		process_x = process_x - 3

		steps_x -= 1

		for i in range(a, b, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x) + str(process_y + i)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x, process_y + i, 655.25 * (tiles_loaded_x_min), 655.25 * (i + steps_y)
			)

			var childnode = get_node(str(process_x + 4) + str(process_y + i))
			remove_child(childnode)

		process_x = process_x + 2

	#load tiles if going towards positive y border
	if tile_distance_y > (tiles_loaded_y_max - 2):
		tiles_loaded_y_max += 1
		tiles_loaded_y_min += 1
		process_y = process_y + 2

		steps_y += 1

		for i in range(a, b, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x + i) + str(process_y)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x + i, process_y, 655.25 * (i + steps_x), 655.25 * (tiles_loaded_y_max - 1)
			)

			var childnode = get_node(str(process_x + i) + str(process_y - 4))
			remove_child(childnode)

		process_y = process_y - 1

	#load tiles if going towards negative y border
	if tile_distance_y < (tiles_loaded_y_min + 2):
		tiles_loaded_y_max -= 1
		tiles_loaded_y_min -= 1
		process_y = process_y - 3

		steps_y -= 1

		for i in range(a, b, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x + i) + str(process_y)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x + i, process_y, 655.25 * (i + steps_x), 655.25 * tiles_loaded_y_min
			)

			var childnode = get_node(str(process_x + i) + str(process_y + 4))
			remove_child(childnode)

		process_y = process_y + 2
