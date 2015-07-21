package kha.network;

import haxe.io.Bytes;
#if sys_server
import js.Node;
import js.node.Buffer;
import js.node.Dgram;
#end

class Server {
	#if sys_server
	private var app: Dynamic;
	//private var udpSocket: DgramSocket;
	private var lastId: Int = -1;
	#end

	public function new(port: Int) {
		#if sys_server
		
		var express = Node.require("express");
		app = express();
		Node.require("express-ws")(app);
		
		app.use('/', untyped __js__("express.static('../html5')"));
		
		app.listen(port);
		
		//udpSocket = Dgram.createSocket("udp4", function (error: Error, bytes: Bytes) { });
		//udpSocket.bind(port + 1);
		#end
	}
	
	public function onConnection(connection: Client->Void): Void {
		#if sys_server
		app.ws('/', function (socket, req) {
			++lastId;
			connection(new WebSocketClient(lastId, socket));
		});
		
		//udpSocket.on('message', function(message: Buffer, info) {
		//	if (compare(message, "JOIN")) {
		//		++lastId;
		//		connection(new UdpClient(lastId, udpSocket, info.address, info.port));
		//	}
		//	//console.log('Received %d bytes from %s:%d\n', message.length, info.address, info.port);
		//});
		#end
	}
	
	#if sys_server
	private static function compare(buffer: Buffer, message: String): Bool {
		if (buffer.length != message.length) return false;
		for (i in 0...buffer.length) {
			if (buffer.readUInt8(i) != message.charCodeAt(i)) return false;
		}
		return true;
	}
	#end
}
