package kha.graphics;

import haxe.io.Bytes;

interface CubeMap {
	var size(get, null): Int;
	function lock(): Bytes;
	function unlock(): Void;
}
