static func load_tile(fn) -> MvtTile:
	var bytes = FileAccess.get_file_as_bytes(fn)
	return MvtTile.read(bytes)

static func load_tile_gz(fn) -> MvtTile:
	var bytes_gz = FileAccess.get_file_as_bytes(fn)
	var bytes = bytes_gz.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	return MvtTile.read(bytes)
