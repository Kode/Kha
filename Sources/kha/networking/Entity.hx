package kha.networking;

import haxe.io.Bytes;

@:autoBuild(kha.networking.EntityBuilder.build())
interface Entity {
	public function id(): Int;
	public function size(): Int;
	//public function simulate(tdif: Float): Void;
	public function _send(offset: Int, bytes: Bytes): Void;
	public function _receive(offset: Int, bytes: Bytes): Void;
}
