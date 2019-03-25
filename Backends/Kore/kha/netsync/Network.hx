package kha.netsync;

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
	private var tempBuffer: Bytes;
	private var listener: Bytes->Void;

	public function new(url: String, port: Int, errorCallback: Void->Void, closeCallback: Void->Void) {
		this.url = url;
		this.port = port + 1; // TODO: This is somewhat ugly, but necessary to maintain both websocket and UPD connections at the same time (see also Server.hx)
		bufferPos = 0;
		buffer = Bytes.alloc(256); // TODO: Size
		tempBuffer = Bytes.alloc(256); // TODO: Size
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
		var received = getBytesFromSocket(tempBuffer);
		buffer.blit(bufferPos, tempBuffer, 0, received);
		bufferPos += received;
		//if (received > 0) trace("received " + received + " bytes");
		
		// TODO: Handle partial packets, don't choke on garbage
		if (listener != null && bufferPos > 0) {
			var result = Bytes.alloc(bufferPos);
			result.blit(0, buffer, 0, bufferPos);
			listener(result);
			bufferPos = 0;
		}
	}

	@:functionCode('
		unsigned int recAddr;
		unsigned int recPort;
		int size = socket->receive((unsigned char*)inBuffer->b->getBase(), inBuffer->length, recAddr, recPort);
		if (size >= 0) {
			return size;
		}
		else {
			return 0;
		}
	')
	private function getBytesFromSocket(inBuffer: Bytes): Int {
		return 0;
	}
}
