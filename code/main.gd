extends Node3D
#@tool
#extends EditorScript

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const CALCULATE_POLYGON = preload("res://src/calculate_polygon_vectors.gd")
const ROADS = preload("res://src/roads.gd")

# key represents the height
const polygon_types = {
	10: ["building", Color(211, 211, 211, 255)],
	2: ["landcover", Color(0, 255, 0, 255)],
	0: ["water", Color(0, 0, 255, 255)],
}

func _ready():
	var start_x = 34317
	var start_y = 42582
	var start_tile_path = "res://tiles/switzerland/16/" + str(start_x) + "/" + str(start_y) + ".pbf"
	
	var tile = MVT.load_tile_gz(start_tile_path)
	
	for height in polygon_types.keys():
		var polygon_type_data = polygon_types[height]
		var polygons = CALCULATE_POLYGON.get_polygon_vectors(tile, polygon_type_data[0])
		for polygon in polygons:
			var color = polygon_type_data[1]
			add_child(CALCULATE_POLYGON.generate_polygon(polygon, height, color))
			
	for layer in tile.layers():
		if layer.name() == "transportation":
			for feature in layer.features():
				ROADS.generate_paths(ROADS.build_road_geometries(feature.geometry()), self)
	
func _process(delta):
	pass
