package kha.networking;

import haxe.io.Bytes;

interface Client {
	function send(bytes: Bytes, mandatory: Bool): Void;
	function onClose(close: Void->Void): Void;
}
