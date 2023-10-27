extends Node3D
#@tool
#extends EditorScript

const MVT = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
var calculate_polygon_script = preload("res://src/calculate_polygon_vectors.gd")

func _ready():
	var start_x = 34316
	var start_y = 42581
	var start_tile_path = "res://tiles/switzerland/16/" + str(start_x) + "/" + str(start_y) + ".pbf"
	
	var tile = MVT.load_tile_gz(start_tile_path)
	
	var buildings = calculate_polygon_script.get_polygon_vectors(tile)
	for building in buildings:
		#print(building)
		var polygon = calculate_polygon_script.generate_polygon(building)
		add_child(polygon)
	
func _process(delta):
	pass
