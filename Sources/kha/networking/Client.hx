package kha.networking;

import haxe.io.Bytes;

class Client {
	private var socket: Dynamic;
	
	public function new(socket: Dynamic) {
		this.socket = socket;
	}
	
	public function send(bytes: Bytes): Void {
		socket.send(bytes.getData());
	}
	
	public function onClose(close: Void->Void): Void {
		socket.onclose = function () {
			close();
		};
	}
}
