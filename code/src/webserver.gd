extends Node

signal download_completed(success)

func downloadFile(x, y):
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var download_http = "https://tiles.streets.gl/vector/16/" + str(x) + "/" + str(y)
	var download_local = "res://tiles/" + str(x) + str(y) 

	http_request.download_file = download_local

	http_request.request_completed.connect(_on_request_completed)
	http_request.request(download_http)
	
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		emit_signal("download_completed", true)
	else:
		emit_signal("download_completed", false)
