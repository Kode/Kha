package kha.netsync;

import haxe.io.Bytes;

class LocalClient implements Client {
	var myId: Int;

	public function new(id: Int) {
		myId = id;
	}

	public function send(bytes: Bytes, mandatory: Bool): Void {}

	public function receive(receiver: Bytes->Void): Void {}

	public function onClose(close: Void->Void): Void {}

	public var controllers(get, null): Array<Controller>;

	function get_controllers(): Array<Controller> {
		return null;
	}

	public var id(get, null): Int;

	function get_id(): Int {
		return myId;
	}
}
