package system.diagnostics;

import haxe.Int64;

@:native("System.Diagnostics.Stopwatch")
extern class Stopwatch {
	public function new(): Void;
	public function Start(): Void;
	public var ElapsedMilliseconds: Int64;
}