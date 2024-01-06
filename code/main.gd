extends Node3D

############################
#Set start position here
#const START_X = 58210
#const START_Y = 25805
###########################

const START_X = 34319
const START_Y = 22950

#DO NOT TOUCH!!!
const MVT_READER = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const WEBSERVER = preload("res://src/webserver.gd")
const CONSTANTS = preload("res://src/common/constants.gd")
const POLYGON_VECTOR_CALCULATOR = preload("res://src/polygons/calculate_polygon_vectors.gd")
const POLYGON_HEIGHT_CALCULATOR = preload("res://src/polygons/calculate_polygon_heights.gd")
const POLYGON_BUILDER = preload("res://src/polygons/build_polygons.gd")
const LINESTRING_VECTOR_CALCULATOR = preload(
	"res://src/linestrings/calculate_linestring_vectors.gd"
)
const LINESTRING_BUILDER = preload("res://src/linestrings/build_linestrings.gd")
const POINTS = preload("res://src/points/pois.gd")
const FLOOR_BUILDER = preload("res://src/common/create_floor.gd")

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
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			process_x = START_X + i
			process_y = START_Y + j
			webserver.download_file(
				process_x, process_y, CONSTANTS.OFFSET * i, CONSTANTS.OFFSET * j
			)
	process_x = START_X
	process_y = START_Y


func _on_download_completed(success, current_x, current_y, offset_x, offset_y):
	if success:
		print("download successfull for: x=", current_x, ", ", current_y)
		render_geometries(current_x, current_y, offset_x, offset_y)
	else:
		print("Download failed or timed out.")


func render_geometries(x, y, offset_x, offset_y):
	var tilepath = "res://tiles/" + str(x) + str(y)
	var tile = MVT_READER.load_tile(tilepath)

	var tile_node_current = Node3D.new()
	tile_node_current.name = str(x + offset_x) + str(y + offset_y)

	FLOOR_BUILDER.build_floor(tile_node_current, offset_x, offset_y)

	for layer in tile.layers():
		if layer.name() == CONSTANTS.HIGHWAYS:
			for feature in layer.features():
				var width = null
				if feature.tags(layer).has("pathType"):
					if CONSTANTS.WIDTHS.has(feature.tags(layer).pathType):
						width = CONSTANTS.WIDTHS[feature.tags(layer).pathType]
					
				var linestring_geometries = (
					LINESTRING_VECTOR_CALCULATOR.build_linestring_geometries(feature.geometry())
				)
				LINESTRING_BUILDER.generate_paths(
					linestring_geometries,
					tile_node_current,
					Color(0, 0, 0, 1),
					offset_x,
					offset_y,
					width
				)

		if layer.name() == CONSTANTS.BUILDINGS:
			for feature in layer.features():
				var polygon_height = POLYGON_HEIGHT_CALCULATOR.get_polygon_height(feature, layer)

				var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
					feature.geometry()
				)
				var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
					sanitized_geometries
				)

				POLYGON_BUILDER.generate_polygons(
					polygon_geometries,
					tile_node_current,
					Color(0.5, 0.5, 0.5, 1.0),
					offset_x,
					offset_y,
					polygon_height
				)

		if layer.name() == CONSTANTS.COMMON:
			for feature in layer.features():
				var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
					feature.geometry()
				)
				var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
					sanitized_geometries
				)

				POLYGON_BUILDER.generate_polygons(
					polygon_geometries,
					tile_node_current,
					Color(0.133, 0.545, 0.133, 1.0),
					offset_x,
					offset_y,
					0.5
				)

		if layer.name() == CONSTANTS.WATER:
			for feature in layer.features():
				var type = feature.geom_type()
				if type["GeomType"] == "LINESTRING":
					var linestring_geometries = (
						LINESTRING_VECTOR_CALCULATOR.build_linestring_geometries(feature.geometry())
					)
					LINESTRING_BUILDER.generate_paths(
						linestring_geometries,
						tile_node_current,
						Color(0.004, 0.34, 0.61, 0.4),
						offset_x,
						offset_y
					)

				if type["GeomType"] == "POLYGON":
					var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
						feature.geometry()
					)
					var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
						sanitized_geometries
					)

					POLYGON_BUILDER.generate_polygons(
						polygon_geometries,
						tile_node_current,
						Color(0.004, 0.34, 0.61, 0.4),
						offset_x,
						offset_y
					)

		if layer.name() == CONSTANTS.POINT:
			POINTS.generate_pois(tile, tile_node_current, offset_x, offset_y)

		if layer.name() == CONSTANTS.NATURAL:
			for feature in layer.features():
				var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
					feature.geometry()
				)
				var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
					sanitized_geometries
				)

				POLYGON_BUILDER.generate_polygons(
					polygon_geometries,
					tile_node_current,
					Color(0.21, 0.42, 0.21, 1),
					offset_x,
					offset_y,
					0.5
				)

	add_child(tile_node_current)

# _process needs an argument, even if its never used
# gdlint:ignore = unused-argument
func _process(delta):
	var tile_distance_x = int($Player.position.x / CONSTANTS.OFFSET)
	var tile_distance_y = int($Player.position.z / CONSTANTS.OFFSET)

	#load tiles if going to wards positive x loaded border
	if tile_distance_x > (tiles_loaded_x_max - 2):
		tiles_loaded_x_max += 1
		tiles_loaded_x_min += 1
		process_x = process_x + 2

		steps_x += 1

		for i in range(-2, 2, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x,
				process_y + i,
				CONSTANTS.OFFSET * (tiles_loaded_x_max - 1),
				CONSTANTS.OFFSET * (i + steps_y)
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

		for i in range(-2, 2, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x,
				process_y + i,
				CONSTANTS.OFFSET * (tiles_loaded_x_min),
				CONSTANTS.OFFSET * (i + steps_y)
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

		for i in range(-2, 2, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x + i,
				process_y,
				CONSTANTS.OFFSET * (i + steps_x),
				CONSTANTS.OFFSET * (tiles_loaded_y_max - 1)
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

		for i in range(-2, 2, 1):
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x + i,
				process_y,
				CONSTANTS.OFFSET * (i + steps_x),
				CONSTANTS.OFFSET * tiles_loaded_y_min
			)

			var childnode = get_node(str(process_x + i) + str(process_y + 4))
			remove_child(childnode)

		process_y = process_y + 2
