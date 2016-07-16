package kha.network;

import haxe.io.Bytes;
import js.html.BinaryType;
import js.html.WebSocket;

class Network {
	private var socket: WebSocket;
	private var open: Bool = false;
	
	public function new(url: String, port: Int) {
		socket = new WebSocket("ws://" + url + ":" + port);
		socket.binaryType = BinaryType.ARRAYBUFFER;
		socket.onopen = function () {
			open = true;
		};
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
