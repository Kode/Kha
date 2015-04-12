package kha.networking;

import haxe.io.Bytes;

class WebSocketClient implements Client {
	private var socket: Dynamic;
	
	public function new(socket: Dynamic) {
		this.socket = socket;
	}
	
	public function send(bytes: Bytes, mandatory: Bool): Void {
		socket.send(bytes.getData());
		//socket.send(bytes.getData(), {binary: true});
	}
	
	public function onClose(close: Void->Void): Void {
		socket.onclose = function () {
			close();
		};
	}
}
