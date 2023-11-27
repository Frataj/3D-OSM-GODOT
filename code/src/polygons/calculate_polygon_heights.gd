const HEIGHT_IN_LEVELS = "levels"
const HEIGHT_IN_METERS = "height"

static func get_polygon_height(feature, layer, type):
	var heights = []
	
	var tag = feature.tags(layer)
				
	if tag.has(HEIGHT_IN_LEVELS):
		heights.append(tag[HEIGHT_IN_LEVELS] * 2.75)
	elif tag.has(HEIGHT_IN_METERS):
		heights.append(tag[HEIGHT_IN_METERS])
	else:
		heights.append(2.75)
					
	return heights
