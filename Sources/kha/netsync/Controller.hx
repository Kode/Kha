package kha.netsync;

import haxe.io.Bytes;

@:autoBuild(kha.netsync.ControllerBuilder.build())
class Controller {
	var __id: Int;

	public var _inputBufferIndex: Int;
	public var _inputBuffer: Bytes;

	public function new() {
		__id = ControllerBuilder.nextId++;
		_inputBuffer = Bytes.alloc(1);
	}

	public function _id(): Int {
		return __id;
	}

	public function _receive(bytes: Bytes): Void {}
}
