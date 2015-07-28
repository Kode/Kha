package kha.network;

import haxe.io.Bytes;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Network/Http.h>
')

@:headerClassCode('
	static void internalCallback(int error, int response, const char* body, void* data) {
		int callbackindex = (int)(Kore::spint)data;
		internalCallback2(error, response, callbackindex);
	}
')
class Http {
	private static var callbacks: Array<Int->Int->String->Void>;

	@:functionCode('
		Kore::httpRequest(url, path, data, port, secure, (Kore::HttpMethod)method, internalCallback, (void*)callbackindex);
	')
	private static function request2(url: String, path: String, data: String, port: Int, secure: Bool, method: Int, callbackindex: Int): Void {

	}

	private static function internalCallback2(error: Int, response: Int, callbackindex: Int): Void {
		callbacks[callbackindex](error, response, null);
	}
	
	private static function convertMethod(method: HttpMethod): Int {
		switch (method) {
			case Get:
				return 0;
			case Post:
				return 1;
			case Put:
				return 2;
			case Delete:
				return 3;
			default:
				return 0;
		}
	}
	
	public static function request(url: String, path: String, data: String, port: Int, secure: Bool, method: HttpMethod, contentType: String, callback: Int->Int->String->Void /*error, response, body*/): Void {
		if (callbacks == null) {
			callbacks = new Array<Int->Int->String->Void>();
		}
		var index = callbacks.length;
		callbacks.push(callback);
		request2(url, path, data, port, secure, convertMethod(method), index);
	}
}
