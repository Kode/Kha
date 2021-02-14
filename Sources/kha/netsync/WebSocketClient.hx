package kha.netsync;

import haxe.io.Bytes;

class WebSocketClient implements Client {
	var myId: Int;
	var socket: Dynamic;

	public function new(id: Int, socket: Dynamic) {
		myId = id;
		this.socket = socket;
	}

	public function send(bytes: Bytes, mandatory: Bool): Void {
		socket.send(bytes.getData());
		// socket.send(bytes.getData(), {binary: true});
	}

	public function receive(receiver: Bytes->Void): Void {
		socket.on('message', function(message) {
			// js.Node.console.log(message);
			receiver(Bytes.ofData(message));
		});
	}

	public function onClose(close: Void->Void): Void {
		socket.onclose = function() {
			close();
		};
	}

	public var controllers(get, null): Array<Controller>;

	function get_controllers(): Array<Controller> {
		return null;
	}

	public var id(get, null): Int;

	function get_id(): Int {
		return myId;
	}
}
