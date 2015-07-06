package kha.network;

import haxe.io.Bytes;
import js.html.XMLHttpRequest;

class Http {
	private static function methodToString(method: HttpMethod): String {
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
	
	public static function request(url: String, path: String, data: String, port: Int, secure: Bool, method: HttpMethod, contentType: String, callback: Int->Int->String->Void /*error, response, body*/): Void {
		var req = new XMLHttpRequest("");
		var completeUrl = secure ? "https://" : "http://" + url + ":" + port + "/" + path;
		req.open(methodToString(method), completeUrl, true);
		if (contentType != null) req.setRequestHeader("Content-type", contentType);
		req.onreadystatechange = function () {
			if (req.readyState != 4) return;
			if (req.status != 200)  {
				callback(1, req.status, null);
				return;
			}
			callback(0, req.status, req.responseText);
		}
		req.send(data);
	}
}
