package kha.network;

import haxe.io.Bytes;
#if js
import js.Node;
import js.node.Buffer;
#end

class NodeProcessClient implements Client {
	private var myId: Int = -1;
	private var receiveCallback: Bytes->Void = null;
	private var closeCallback: Void->Void = null;
	
	public function new(id: Int) {
		myId = id;
	}
	
	public function send(bytes: Bytes, mandatory: Bool): Void {
		#if js
		var data = bytes.getData();
		var buffer = untyped __js__("new Buffer(data)");
		Node.process.send({data: buffer.toString(), id: myId});
		#end
	}
	
	public function receive(receiver: Bytes->Void): Void {
		receiveCallback = receiver;
	}
	
	public function _message(data): Void {
		if (receiveCallback != null) {
			receiveCallback(Bytes.ofString(data));
		}
	}
	
	public function onClose(close: Void->Void): Void {
		closeCallback = close;
	}
	
	public function _close(): Void {
		if (closeCallback != null) {
			closeCallback();
		}
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
