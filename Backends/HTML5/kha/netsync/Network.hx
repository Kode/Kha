package kha.netsync;

import haxe.io.Bytes;
import js.html.BinaryType;
import js.html.WebSocket;

class Network {
	private var socket: WebSocket;
	private var open: Bool = false;
	
	public function new(url: String, port: Int, errorCallback: Void->Void, closeCallback: Void->Void) {
		socket = new WebSocket("ws://" + url + ":" + port);
		socket.onerror = function (error) {
			trace("Network error.");
			errorCallback();
		}
		socket.binaryType = BinaryType.ARRAYBUFFER;
		socket.onopen = function () {
			open = true;
		};
		socket.onclose = function (event) {
			trace("Network connection closed. " + webSocketCloseReason(event.code) + " (" + event.reason + ").");
			closeCallback();
		}
	}

	static function webSocketCloseReason(code: Int): String {
		switch (code) {
			case 1000: return "Normal Closure";
			case 1001: return "Going Away";
			case 1002: return "Protocol error";
			case 1003: return "Unsupported Data";
			case 1005: return "No Status Rcvd";
			case 1006: return "Abnormal Closure";
			case 1007: return "Invalid frame";
			case 1008: return "Policy Violation";
			case 1009: return "Message Too Big";
			case 1010: return "Mandatory Ext.";
			case 1011: return "Internal Server Error";
			case 1015: return "TLS handshake";
			default: return "";
		}
	}
	
	public function send(bytes: Bytes, mandatory: Bool): Void {
		if (open) socket.send(bytes.getData());
	}
	
	public function listen(listener: Bytes->Void): Void {
		socket.onmessage = function (message) {
			listener(Bytes.ofData(message.data));
		};
	}
}
