package kha.networking;

import haxe.io.Bytes;
import js.node.Buffer;
import js.node.Dgram.DgramSocket;
import js.support.Error;

class UdpClient implements Client {
	private var socket: DgramSocket;
	private var address: String;
	private var port: Int;
	
	public function new(socket: DgramSocket, address: String, port: Int) {
		this.socket = socket;
		this.address = address;
		this.port = port;
	}
	
	public function send(bytes: Bytes, mandatory: Bool): Void {
		var buffer = new Buffer(bytes.length);
		for (i in 0...bytes.length) {
			buffer[i] = bytes.get(i);
		}
		socket.send(buffer, 0, bytes.length, port, address, function (error: Error) {
			
		});
	}
	
	public function onClose(close: Void->Void): Void {
		
	}
}
