package kha.network;

import haxe.io.Bytes;

class LocalClient implements Client {
	private var myId: Int;
	
	public function new(id: Int) {
		myId = id;
	}
	
	public function send(bytes: Bytes, mandatory: Bool): Void {
		
	}
	
	public function receive(receiver: Bytes->Void): Void {
		
	}
	
	public function onClose(close: Void->Void): Void {
		
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
