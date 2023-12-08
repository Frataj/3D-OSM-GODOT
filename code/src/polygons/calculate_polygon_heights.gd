const HEIGHT_IN_LEVELS = "levels"
const HEIGHT_IN_METERS = "height"


static func get_polygon_height(feature, layer):
	var heights = 0

	var tag = feature.tags(layer)

	if tag.has(HEIGHT_IN_LEVELS):
		heights = tag[HEIGHT_IN_LEVELS] * 2.75
		#heights.append(tag[HEIGHT_IN_LEVELS] * 2.75)
	elif tag.has(HEIGHT_IN_METERS):
		heights = tag[HEIGHT_IN_METERS]
		#heights.append(tag[HEIGHT_IN_METERS])
	else:
		#heights.append(2.75)
		heights = 2.75
	return heights
