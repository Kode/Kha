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
	public static inline var START = 0;
	public static inline var ENTITY_UPDATES = 1;
	public static inline var CONTROLLER_UPDATES = 2;
	
	private static var instance: Session;
	private var entities: Map<Int, Entity> = new Map();
	private var controllers: Map<Int, Controller> = new Map();
	private var minPlayers: Int;
	private var maxPlayers: Int;
	private var startCallback: Void->Void;
	#if node
	private var server: Server;
	private var clients: Array<Client> = new Array();
	private var current: Client;
	#else
	private var localClient: Client;
	public var network: Network;
	#end
	
	public var me(get, null): Client;
	
	private function get_me(): Client {
		#if node
		return current;
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
		entities.set(entity._id(), entity);
	}
	
	public function addController(controller: Controller): Void {
		controllers.set(controller._id(), controller);
	}
	
	private function send(): Bytes {
		#if node
		var size = 0;
		for (entity in entities) {
			size += entity._size();
		}
		var offset = 0;
		var bytes = Bytes.alloc(size + 9);
		bytes.set(offset, ENTITY_UPDATES);
		offset += 1;
		bytes.setDouble(offset, Scheduler.time());
		offset += 8;
		for (entity in entities) {
			entity._send(offset, bytes);
			offset += entity._size();
		}
		return bytes;
		#else
		/*var size = 0;
		for (controller in controllers) {
			size += controller._size();
		}
		var offset = 0;
		var bytes = Bytes.alloc(size + 1);
		bytes.set(0, CONTROLLER_UPDATES);
		offset += 1;
		for (controller in controllers) {
			controller._send(offset, bytes);
			offset += controller._size();
		}
		return bytes;*/
		return null;
		#end
	}
	
	public function receive(bytes: Bytes): Void {
		#if node
		switch (bytes.get(0)) {
		case CONTROLLER_UPDATES:
			var id = bytes.getInt32(1);
			var time = bytes.getDouble(5);
			Scheduler.addTimeTask(function () { controllers[id]._receive(13, bytes); }, time - Scheduler.time());
		}
		#else
		switch (bytes.get(0)) {
		case START:
			var index = bytes.get(1);
			localClient = new LocalClient(index);
			Scheduler.resetTime();
			startCallback();
		case ENTITY_UPDATES:
			var time = bytes.getDouble(1);
			var offset = 9;
			for (entity in entities) {
				entity._receive(offset, bytes);
				offset += entity._size();
			}
			Scheduler.back(time);
		}
		#end
	}
	
	public function waitForStart(callback: Void->Void): Void {
		startCallback = callback;
		#if node
		server = new Server(6789);
		server.onConnection(function (client: Client) {
			clients.push(client);
			current = client;
			
			Node.console.log(clients.length + " client" + (clients.length > 1 ? "s " : " ") + "connected.");
			
			client.receive(function (bytes: Bytes) {
				current = client;
				receive(bytes);
			});
			
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
				Scheduler.resetTime();
				startCallback();
			}
		});
		#else
		network = new Network("localhost", 6789);
		network.listen(receive);
		#end
	}
	
	public function update(): Void {
		#if node
		for (client in clients) {
			client.send(send(), false);
		}
		#else
		//network.send(send(), false);
		#end
	}
}
