package kha.network;

import haxe.io.Bytes;
import js.html.BinaryType;
import js.html.WebSocket;

class Network {
	private var socket: WebSocket;
	private var open: Bool = false;
	
	public function new(url: String, port: Int, errorCallback: Void->Void, closeCallback: Void->Void) {
		socket = new WebSocket("ws://" + url + ":" + port);
		socket.onerror = function (error) {
			trace("Network error: " + error);
			errorCallback();
		}
		socket.binaryType = BinaryType.ARRAYBUFFER;
		socket.onopen = function () {
			open = true;
		};
		socket.onclose = function (event) {
			trace("Network connection closed");
			closeCallback();
		}
	}
	
	public function send(bytes: Bytes, mandatory: Bool): Void {
		if (open) socket.send(bytes.getData());
	}
	
	public function listen(listener: Bytes->Void): Void {
		socket.onmessage = function (message) {
			listener(Bytes.ofData(message.data));
		};
	}
}
