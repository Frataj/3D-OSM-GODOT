const CONSTANTS = preload("res://src/common/constants.gd")


static func get_polygon_height(feature, layer):
	var heights = 0

	var tag = feature.tags(layer)

	if tag.has(CONSTANTS.HEIGHT_IN_LEVELS):
		heights = tag[CONSTANTS.HEIGHT_IN_LEVELS] * 2.75
	elif tag.has(CONSTANTS.HEIGHT_IN_METERS):
		heights = tag[CONSTANTS.HEIGHT_IN_METERS]
	else:
		heights = 2.75
	return heights
