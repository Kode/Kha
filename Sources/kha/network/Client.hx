package kha.network;

import haxe.io.Bytes;

interface Client {
	var id(get, null): Int;
	function send(bytes: Bytes, mandatory: Bool): Void;
	function receive(receiver: Bytes->Void): Void;
	function onClose(close: Void->Void): Void;
}
