package kha.network;

import haxe.io.Bytes;

@:autoBuild(kha.network.EntityBuilder.build())
interface Entity {
	function _id(): Int;
	function _size(): Int;
	function _send(offset: Int, bytes: Bytes): Int;
	function _receive(offset: Int, bytes: Bytes): Int;
}
