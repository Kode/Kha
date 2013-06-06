package kha.graphics;

import haxe.io.Bytes;
import kha.Image;

interface Texture extends Image {
	var realWidth(get, null): Int;
	var realHeight(get, null): Int;
	function lock(): Bytes;
	function unlock(): Void;
}
