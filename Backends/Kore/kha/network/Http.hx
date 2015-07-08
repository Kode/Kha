package kha.network;

import haxe.io.Bytes;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Network/Http.h>
')

class Http {
	@:functionCode('
		Kore::httpRequest(url, path, data, port, secure, (Kore::HttpMethod)method);
	')
	private static function request2(url: String, path: String, data: String, port: Int, secure: Bool, method: Int, callback: Int->Int->String->Void /*error, response, body*/): Void {
		
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
		request2(url, path, data, port, secure, convertMethod(method), callback);
	}
}
