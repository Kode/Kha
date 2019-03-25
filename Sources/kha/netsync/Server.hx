package kha.netsync;

import haxe.io.Bytes;
#if sys_server
import js.Node;
import js.node.Buffer;
import js.node.Dgram;
#end

class Server {
	#if sys_server
	
	private var app: Dynamic;
	private var udpSocket: Dynamic;
	private var udpClients: Map<String, UdpClient> = new Map();
	private var lastId: Int = -1;
	
	#if !direct_connection
	
	private var clients: Map<Int, NodeProcessClient> = new Map();
	private var connectionCallback: Client->Void;
	
	#end
	
	#end

	public function new(port: Int) {
		#if sys_server
		
		#if direct_connection
		
		var express = Node.require("express");
		app = express();
		Node.require("express-ws")(app);
		
		app.use('/', untyped __js__("express.static('../html5')"));
		
		app.use(function(err, req, res, next) {
			Node.console.error(err.stack);
		});

		app.listen(port);
		
		udpSocket = Dgram.createSocket("udp4");
		udpSocket.bind(port + 1); // TODO: This is somewhat ugly, but necessary to maintain both websocket and UPD connections at the same time (see also kore/network/Network.hx)
		
		#else
		
		Node.process.on("message", function (message) {
			var msg: String = message.message;
			switch (msg) {
				case "connect": {
					var id: Int = message.id;
					var client = new NodeProcessClient(id);
					clients[id] = client;
					connectionCallback(client);
				}
				case "disconnect": {
					var id: Int = message.id;
					var client = clients[id];
					client._close();
					clients.remove(id);
				}
				case "message": {
					var id: Int = message.id;
					var client = clients[id];
					client._message(message.data);
				}
			}
		});
		
		#end
		
		#end
	}
	
	public function onConnection(connection: Client->Void): Void {
		#if sys_server
		
		#if direct_connection
		
		app.ws('/', function (socket, req) {
			++lastId;
			connection(new WebSocketClient(lastId, socket));
		});
		
		udpSocket.on('message', function(message: Buffer, info) {
			if (compare(message, "JOIN")) {
				++lastId;
				var client = new UdpClient(lastId, udpSocket, info.address, info.port);
				udpClients.set(info.address + info.port, client);
				connection(client);
				//var content = Bytes.alloc(4);
				//content.setInt32(0, lastId);
				//client.send(content, true);
			}
			else {
				var client = udpClients.get(info.address + info.port);
				if (client != null) {
					if (client.onReceive != null) {
						var data: haxe.io.BytesData = cast message;
						client.onReceive(Bytes.ofData(data));
					}
				}
				// TODO
				/*var id: Int = message[0];
				var client = clients[id];
				var content = Bytes.alloc(message.length - 1);
				content.blit(0, message, 1, message.length);
				client._message(message.length);*/
			}
			// TODO: Timeout for disconnect
			//console.log('Received %d bytes from %s:%d\n', message.length, info.address, info.port);
		});
		
		#else
		
		connectionCallback = connection;
		
		#end
		
		#end
	}

	public function reset(): Void {
		#if sys_server
		lastId = -1;
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
