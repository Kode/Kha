package kha.network;

import haxe.io.Bytes;

extern class Http {
	public static function request(url: String, path: String, data: String, port: Int, secure: Bool, method: HttpMethod, headers: Map<String, String>,
		callback: Int->Int->String->Void /*error, response, body*/): Void;
}
