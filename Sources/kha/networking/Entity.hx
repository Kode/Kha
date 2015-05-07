package kha.networking;

import haxe.io.Bytes;

@:autoBuild(kha.networking.EntityBuilder.build())
interface Entity {
	function _id(): Int;
	function _size(): Int;
	function _send(offset: Int, bytes: Bytes): Void;
	function _receive(offset: Int, bytes: Bytes): Void;
}
