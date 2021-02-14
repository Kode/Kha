package kha.network;

import haxe.io.Bytes;

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
		var completeUrl = (secure ? "https://" : "http://") + url + ":" + port + "/" + path;
		var address: haxe.Http = new haxe.Http(completeUrl);
		address.onData = function receiveData(data: String): Void {
			callback(0, 200, data);
		};
		address.onError = function receiveErrorData(data: String): Void {
			// data in this case is the error message
			callback(1, 404, data);
		};
		for (key => value in headers) {
			address.addHeader(key, value);
		}
		if (methodToString(method) == 'POST') {
			address.setPostData(data);
			address.request(true);
		}
		else {
			address.request();
		}
	}
}
