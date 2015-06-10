package kha.networking;

import haxe.io.Bytes;
#if node
import js.node.Buffer;
import js.node.Dgram.DgramSocket;
import js.support.Error;
#end

class UdpClient implements Client {
	private var myId: Int;
	#if node
	private var socket: DgramSocket;
	#end
	private var address: String;
	private var port: Int;

	#if node
	public function new(id: Int, socket: DgramSocket, address: String, port: Int) {
		myId = id;
		this.socket = socket;
		this.address = address;
		this.port = port;
	}
	#end

	public function send(bytes: Bytes, mandatory: Bool): Void {
		#if node
		var buffer = new Buffer(bytes.length);
		for (i in 0...bytes.length) {
			buffer[i] = bytes.get(i);
		}
		socket.send(buffer, 0, bytes.length, port, address, function (error: Error) {
			
		});
		#end
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
