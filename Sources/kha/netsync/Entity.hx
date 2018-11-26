package kha.netsync;

import haxe.io.Bytes;

@:autoBuild(kha.netsync.EntityBuilder.build())
interface Entity {
	function _id(): Int;
	function _size(): Int;
	function _send(offset: Int, bytes: Bytes): Int;
	function _receive(offset: Int, bytes: Bytes): Int;
}
