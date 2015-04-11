package kha.networking;

import js.Node;

class Server {
	private var wss: Dynamic;
	
	public function new(port: Int) {
		var WebSocketServer = Node.require("ws").Server;
		wss = untyped __js__("new WebSocketServer({ port: port })");
	}
	
	public function onConnection(connection: Client->Void): Void {
		wss.on("connection", function (socket: Dynamic) {
			connection(new Client(socket));
		});
	}
}
