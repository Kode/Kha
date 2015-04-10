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
	private var clients: Array<Client> = new Array();
	private var entities: Map<Int, Entity> = new Map();
	#if node
	private var wss: Dynamic;
	private var sockets: Array<Dynamic> = new Array();
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
		var WebSocketServer = Node.require("ws").Server;
		wss = untyped __js__("new WebSocketServer({ port: 6789 })");
		wss.on("connection", function (socket: Dynamic) {
			Node.console.log("Client connected.");
			sockets.push(socket);
		});
		#else
		var socket = new WebSocket("ws://localhost:6789");
		socket.binaryType = BinaryType.ARRAYBUFFER;
		socket.onmessage = function (message) {
			var bytes = Bytes.ofData(message.data);
			receiveState(bytes);
		};
		#end
	}
	
	public function update(): Void {
		#if node
		for (socket in sockets) {
			var bytes = sendState();
			socket.send(bytes.getData());
		}
		#end
	}
}
