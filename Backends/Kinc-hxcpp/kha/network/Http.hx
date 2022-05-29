package kha.network;

@:headerCode("
#include <kinc/network/http.h>
")
@:headerClassCode("
	static void internalCallback(int error, int response, const char* body, void* data) {
		int callbackindex = (int)(intptr_t)data;
		if (error == 0) {
			size_t length = strlen(body);
			HX_CHAR* chars = hx::NewString(length);
			for (int i = 0; i < length; ++i) {
				chars[i] = body[i];
			}
			internalCallback2(error, response, String(chars, length), callbackindex);
		}
		else {
			internalCallback2(error, response, null(), callbackindex);
		}
	}
")
class Http {
	static var callbacks: Array<Int->Int->String->Void>;

	@:functionCode("kinc_http_request(url, path, data, port, secure, method, header, internalCallback, (void*)callbackindex);")
	static function request2(url: String, path: String, data: String, port: Int, secure: Bool, method: Int, header: String, callbackindex: Int): Void {}

	static function internalCallback2(error: Int, response: Int, body: String, callbackindex: Int): Void {
		callbacks[callbackindex](error, response, body);
	}

	public static function request(url: String, path: String, data: String, port: Int, secure: Bool, method: HttpMethod, headers: Map<String, String>,
			callback: Int->Int->String->Void /*error, response, body*/): Void {
		if (callbacks == null) {
			callbacks = new Array<Int->Int->String->Void>();
		}
		var index = callbacks.length;
		callbacks.push(callback);
		var header = "";
		for (key in headers.keys()) {
			header += key + ": " + headers[key] + "\r\n";
		}
		request2(url, path, data, port, secure, method, header, index);
	}
}
