package kha.network;

import haxe.io.Bytes;

@:headerCode('
#include <Kore/Network/Socket.h>
')

@:headerClassCode('
	Kore::Socket *socket;
')
class Network {
	private var url: String;
	private var port: Int;

	public function new(url: String, port: Int, errorCallback: Void->Void, closeCallback: Void->Void) {
		this.url = url;
		this.port = port + 1; // TODO: This is somewhat ugly, but necessary to maintain both websocket and UPD connections at the same time (see also Server.hx)
		init(url, port);
	}

	@:functionCode('
		socket = new Kore::Socket();
		socket->open(port);
	')
	public function init(url: String, port: Int) {
		send(Bytes.ofString("JOIN"), true); // TODO: Discuss, dependency with Server.hx
	}
	
	@:functionCode('
		// TODO: mandatory
		socket->send(url, port, (const unsigned char*)bytes->b->getBase(), bytes->length);
	')
	public function send(bytes: Bytes, mandatory: Bool): Void {
		
	}

	public function listen(listener: Bytes->Void): Void {
		
	}
}
