package kha.network;

import haxe.io.Bytes;
#if sys_server
import js.node.Http;
import js.Node;
#end
#if js
import js.Browser;
import js.html.BinaryType;
import js.html.WebSocket;
#end
import kha.System;

class State {
	public var time: Float;
	public var data: Bytes;
	
	public function new(time: Float, data: Bytes) {
		this.time = time;
		this.data = data;
	}
}

class Session {
	public static inline var START = 0;
	public static inline var ENTITY_UPDATES = 1;
	public static inline var CONTROLLER_UPDATES = 2;
	public static inline var REMOTE_CALL = 3;
	
	private static var instance: Session = null;
	private var entities: Map<Int, Entity> = new Map();
	private var controllers: Map<Int, Controller> = new Map();
	private var players: Int;
	private var startCallback: Void->Void;
	#if sys_server
	private var server: Server;
	private var clients: Array<Client> = new Array();
	private var current: Client;
	private var lastStates: Array<State> = new Array();
	private static inline var stateCount = 5;
	#else
	private var localClient: Client;
	public var network: Network;
	#end
	
	public var me(get, null): Client;
	
	private function get_me(): Client {
		#if sys_server
		return current;
		#else
		return localClient;
		#end
	}
	
	public function new(players: Int) {
		instance = this;
		this.players = players;
	}
	
	public static function the(): Session {
		return instance;
	}
	
	public function addEntity(entity: Entity): Void {
		entities.set(entity._id(), entity);
	}
	
	public function addController(controller: Controller): Void {
		trace("Adding controller id " + controller._id());
		controllers.set(controller._id(), controller);
	}
	
	#if sys_server
	private function send(): Bytes {
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
		
		lastStates.push(new State(Scheduler.time(), bytes));
		if (lastStates.length > stateCount) {
			lastStates.splice(0, 1);
		}
		
		return bytes;
	}
	#end
	
	public function receive(bytes: Bytes, client: Client = null): Void {
		#if sys_server
		
		switch (bytes.get(0)) {
		case CONTROLLER_UPDATES:
			var id = bytes.getInt32(1);
			var time = bytes.getDouble(5);
			
			var width = bytes.getInt32(13);
			var height = bytes.getInt32(17);
			var rotation = bytes.get(21);
			SystemImpl._updateSize(width, height);
			SystemImpl._updateScreenRotation(rotation);
			
			if (controllers.exists(id)) {
				Scheduler.addTimeTask(function () {
					current = client;
					controllers[id]._receive(22, bytes);
					current = null;					
				}, time - Scheduler.time());
				if (time < Scheduler.time()) {
					var i = lastStates.length - 1;
					while (i >= 0) {
						if (lastStates[i].time < time) {
							var offset = 9;
							for (entity in entities) {
								entity._receive(offset, lastStates[i].data);
								offset += entity._size();
							}
							Scheduler.back(time);
							break;
						}
						--i;
					}
				}
			}
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
		case REMOTE_CALL:
			var args = new Array<Dynamic>();
			var index: Int = 1;
			
			var classnamelength = bytes.getUInt16(index);
			index += 2;
			var classname = "";
			for (i in 0...classnamelength) {
				classname += String.fromCharCode(bytes.get(index));
				++index;
			}
			
			var methodnamelength = bytes.getUInt16(index);
			index += 2;
			var methodname = "";
			for (i in 0...methodnamelength) {
				methodname += String.fromCharCode(bytes.get(index));
				++index;
			}
			
			while (index < bytes.length) {
				var type = bytes.get(index);
				++index;
				switch (type) {
				case 0x42: // B
					var value: Bool = bytes.get(index) == 1;
					++index;
					trace("Bool: " + value);
					args.push(value);
				case 0x46: // F
					var value: Float = bytes.getDouble(index);
					index += 8;
					trace("Float: " + value);
					args.push(value);
				case 0x49: // I
					var value: Int = bytes.getInt32(index);
					index += 4;
					trace("Int: " + value);
					args.push(value);
				case 0x53: // S
					var length = bytes.getUInt16(index);
					index += 2;
					var str = "";
					for (i in 0...length) {
						str += String.fromCharCode(bytes.get(index));
						++index;
					}
					trace("String: " + str);
					args.push(str);
				default:
					trace("Unknown argument type.");
				}
			}
			Reflect.callMethod(null, Reflect.field(Type.resolveClass(classname), methodname + "_remotely"), args);
		}
		
		#end
	}
	
	public function waitForStart(callback: Void->Void): Void {
		startCallback = callback;
		#if sys_server
		trace("Starting server at 6789.");
		server = new Server(6789);
		server.onConnection(function (client: Client) {
			clients.push(client);
			current = client;
			
			Node.console.log(clients.length + " client" + (clients.length > 1 ? "s " : " ") + "connected.");
			
			client.receive(function (bytes: Bytes) {
				receive(bytes, client);
			});
			
			client.onClose(function () {
				Node.console.log("Removing client " + client.id + ".");
				clients.remove(client);
			});
			
			if (clients.length >= players) {
				Node.console.log("Starting game.");
				var index = 0;
				for (c in clients) {
					trace("Starting client " + c.id);
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
		network.listen(function (bytes: Bytes) { receive(bytes); } );
		#end
	}
	
	public function update(): Void {
		#if sys_server
		for (client in clients) {
			client.send(send(), false);
		}
		#end
	}
	
	#if sys_server
	public function sendToEverybody(bytes: Bytes): Void {
		for (client in clients) {
			client.send(bytes, false);
		}
	}
	#end
}
