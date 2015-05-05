package kha.networking;

import haxe.io.Bytes;
#if node
import js.node.Http;
import js.Node;
#end
import js.Browser;
import js.html.BinaryType;
import js.html.WebSocket;

class Session {
	private static inline var START = 0;
	private static inline var ENTITY_UPDATES = 1;
	
	private static var instance: Session;
	private var entities: Map<Int, Entity> = new Map();
	private var minPlayers: Int;
	private var maxPlayers: Int;
	private var startCallback: Void->Void;
	#if node
	private var server: Server;
	private var clients: Array<Client> = new Array();
	#else
	private var localClient: Client;
	#end
	
	public var me(get, null): Client;
	
	private function get_me(): Client {
		#if node
		return clients[0];
		#else
		return localClient;
		#end
	}
	
	public function new(minPlayers: Int, maxPlayers: Int) {
		instance = this;
		this.minPlayers = minPlayers;
		this.maxPlayers = maxPlayers;
	}
	
	public static function the(): Session {
		return instance;
	}
	
	public function addEntity(entity: Entity): Void {
		entities.set(entity.id(), entity);
	}
	
	public function addController(controller: Controller): Void {
		
	}
	
	public function sendState(): Bytes {
		var size = 0;
		for (entity in entities) {
			size += entity.size();
		}
		
		var offset = 0;
		var bytes = Bytes.alloc(size + 1);
		bytes.set(0, ENTITY_UPDATES);
		offset += 1;
		for (entity in entities) {
			entity._send(offset, bytes);
			offset += entity.size();
		}
		return bytes;
	}
	
	public function receiveClientMessage(bytes: Bytes): Void {
		#if !node
		switch (bytes.get(0)) {
		case START:
			var index = bytes.get(1);
			localClient = new LocalClient(index);
			startCallback();
		case ENTITY_UPDATES:
			var offset = 1;
			for (entity in entities) {
				entity._receive(offset, bytes);
				offset += entity.size();
			}
		}
		#end
	}
	
	public function waitForStart(callback: Void->Void): Void {
		startCallback = callback;
		#if node
		server = new Server(6789);
		server.onConnection(function (client: Client) {
			clients.push(client);
			
			Node.console.log(clients.length + " client" + (clients.length > 1 ? "s " : " ") + "connected.");
			
			client.onClose(function () {
				Node.console.log("Removing client " + client.id + ".");
				clients.remove(client);
			});
			
			if (clients.length >= minPlayers) {
				Node.console.log("Starting game.");
				var index = 0;
				for (c in clients) {
					var bytes = Bytes.alloc(2);
					bytes.set(0, START);
					bytes.set(1, index);
					c.send(bytes, true);
					++index;
				}
				startCallback();
			}
		});
		#else
		var network = new Network("localhost", 6789);
		network.listen(receiveClientMessage);
		#end
	}
	
	public function update(): Void {
		#if node
		for (client in clients) {
			client.send(sendState(), false);
		}
		#end
	}
}
