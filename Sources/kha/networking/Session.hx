package kha.networking;

import haxe.io.Bytes;
#if node
import js.npm.SocketIo;
import js.node.Http;
import js.Node;
#end
import js.Browser;
import js.html.BinaryType;
import js.html.WebSocket;

class Session {
	private static var instance: Session;
	private var entities: Map<Int, Entity> = new Map();
	#if node
	private var server: Server;
	private var clients: Array<Client> = new Array();
	#end
	
	public function new() {
		instance = this;
	}
	
	public static function the(): Session {
		return instance;
	}
	
	public function addEntity(entity: Entity): Void {
		entities.set(entity.id(), entity);
	}
	
	public function sendState(): Bytes {
		var size = 0;
		for (entity in entities) {
			size += entity.size();
		}
		
		var offset = 0;
		var bytes = Bytes.alloc(size);
		for (entity in entities) {
			entity._send(offset, bytes);
			offset += entity.size();
		}
		return bytes;
	}
	
	public function receiveState(bytes: Bytes): Void {
		var offset = 0;
		for (entity in entities) {
			entity._receive(offset, bytes);
			offset += entity.size();
		}
	}
	
	public function start(): Void {
		#if node
		server = new Server(6789);
		server.onConnection(function (client: Client) {
			Node.console.log("Client connected.");
			clients.push(client);
			client.onClose(function () {
				clients.remove(client);
			});
		});
		#else
		var network = new Network("localhost", 6789);
		network.listen(receiveState);
		#end
	}
	
	public function update(): Void {
		#if node
		for (client in clients) {
			client.send(sendState());
		}
		#end
	}
}
