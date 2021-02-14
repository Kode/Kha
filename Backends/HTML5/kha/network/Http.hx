package kha.network;

import js.html.XMLHttpRequest;

class Http {
	static function methodToString(method: HttpMethod): String {
		switch (method) {
			case Get:
				return "GET";
			case Post:
				return "POST";
			case Put:
				return "PUT";
			case Delete:
				return "DELETE";
		}
	}

	public static function request(url: String, path: String, data: String, port: Int, secure: Bool, method: HttpMethod, headers: Map<String, String>,
			callback: Int->Int->String->Void /*error, response, body*/): Void {
		var req = new XMLHttpRequest("");
		var completeUrl = (secure ? "https://" : "http://") + url + ":" + port + "/" + path;
		req.open(methodToString(method), completeUrl, true);
		if (headers != null) {
			for (key in headers.keys()) {
				req.setRequestHeader(key, headers[key]);
			}
		}
		req.onreadystatechange = function() {
			if (req.readyState != 4)
				return;
			if (req.status != 200) {
				callback(1, req.status, null);
				return;
			}
			callback(0, req.status, req.responseText);
		}
		req.send(data);
	}
}
