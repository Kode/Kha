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
	private var bufferPos: Int;
	private var buffer: Bytes;
	private var listener: Bytes->Void;

	public function new(url: String, port: Int, errorCallback: Void->Void, closeCallback: Void->Void) {
		this.url = url;
		this.port = port + 1; // TODO: This is somewhat ugly, but necessary to maintain both websocket and UPD connections at the same time (see also Server.hx)
		bufferPos = 0;
		buffer = Bytes.alloc(256);
		init(url, port);
		kha.Scheduler.addFrameTask(update, 0);
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
		this.listener = listener;
	}

	private function update() {
		var received = getBytesFromSocket(Bytes.alloc(256));
		buffer.blit(bufferPos, received, 0, received.length);
		bufferPos += received.length;
		if (received.length > 0) trace("received " + received.length + " bytes");
		
		// TODO: Handle partial packets, don't choke on garbage
		if (listener != null && bufferPos > 0) {
			var result = Bytes.alloc(bufferPos + 1);
			//result.set(0, kha.network.Session.instance.me.id()); // TODO
			result.blit(1, buffer, 0, bufferPos);
			listener(result);
			bufferPos = 0;
		}
	}

	@:functionCode('
		unsigned int recAddr;
		unsigned int recPort;
		int size = socket->receive((unsigned char*)inBuffer->b->getBase(), sizeof(inBuffer), recAddr, recPort);
		if (size >= 0) {
			// TODO: Socket is at full size, not the actual content
			return inBuffer;
		}
	')
	private function getBytesFromSocket(inBuffer: Bytes): Bytes {
		return Bytes.alloc(0);
	}
}
