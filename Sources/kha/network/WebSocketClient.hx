package kha.network;

import haxe.io.Bytes;

class WebSocketClient implements Client {
	private var myId: Int;
	private var socket: Dynamic;
	
	public function new(id: Int, socket: Dynamic) {
		myId = id;
		this.socket = socket;
	}
	
	public function send(bytes: Bytes, mandatory: Bool): Void {
		socket.send(bytes.getData());
		//socket.send(bytes.getData(), {binary: true});
	}
	
	public function receive(receiver: Bytes->Void): Void {
		socket.on('message', function (message) {
			//js.Node.console.log(message);
			receiver(Bytes.ofData(message));
		});
	}
	
	public function onClose(close: Void->Void): Void {
		socket.onclose = function () {
			close();
		};
	}
	
	public var controllers(get, null): Array<Controller>;
	
	public function get_controllers(): Array<Controller> {
		return null;
	}
	
	public var id(get, null): Int;
	
	public function get_id(): Int {
		return myId;
	}
}
