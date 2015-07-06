package kha.network;

import haxe.io.Bytes;

@:autoBuild(kha.network.ControllerBuilder.build())
interface Controller {
	function _id(): Int;
	function _receive(offset: Int, bytes: Bytes): Void;
}
