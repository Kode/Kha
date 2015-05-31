package kha.networking;

import haxe.io.Bytes;

@:autoBuild(kha.networking.ControllerBuilder.build())
interface Controller {
	function _id(): Int;
	function _receive(offset: Int, bytes: Bytes): Void;
}
