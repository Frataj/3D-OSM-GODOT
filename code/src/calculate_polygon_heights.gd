const HEIGHT_IN_LEVELS = "levels"
const HEIGHT_IN_METERS = "height"

static func get_polygon_height(tile, type):
	var heights = []
	var layers = tile.layers()
	
	for layer in layers:
		if layer.name() == type:
			for feature in layer.features():
				var tag = feature.tags(layer)
				
				if tag.has(HEIGHT_IN_LEVELS):
					heights.append(tag[HEIGHT_IN_LEVELS] * 2.75)
				elif tag.has(HEIGHT_IN_METERS):
					heights.append(tag[HEIGHT_IN_METERS])
				else:
					heights.append(2.75)
					
	return heights
