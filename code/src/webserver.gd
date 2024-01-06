extends Node

signal download_completed(success, tile, x, y, offset_x, offset_y)

var current_x = 0
var current_y = 0
var offset_x = 0
var offset_y = 0

func download_file(x, y, offset_x, offset_y):
	self.current_x = x
	self.current_y = y
	self.offset_x = offset_x
	self.offset_y = offset_y
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var download_http = "https://tiles.streets.gl/vector/16/" + str(x) + "/" + str(y)

	http_request.request_completed.connect(_on_request_completed)
	http_request.request(download_http)

# parameters are required regardles of usage
# gdlint:ignore = unused-argument
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var tile = MvtTile.read(body)
		download_completed.emit(true, tile, current_x, current_y, offset_x, offset_y)
	else:
		download_completed.emit(false, null, current_x, current_y, offset_x, offset_y)
