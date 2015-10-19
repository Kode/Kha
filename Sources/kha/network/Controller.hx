package kha.network;

import haxe.io.Bytes;

@:autoBuild(kha.network.ControllerBuilder.build())
class Controller {
	private var __id: Int;
	
	public function new() {
		__id = ControllerBuilder.nextId++;
	}

	public function _id(): Int {
		return __id;
		
	}

	public function _receive(offset: Int, bytes: Bytes): Void {
		
	}
}
