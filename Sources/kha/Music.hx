package kha;

import haxe.io.Bytes;

/**
 * This represents a Music file.
 */
class Music implements Resource {
	public function new() {
		_nativemusic = null;
	}
	
	/**
	 * The music file in a bytes.
	 */
	public var data: Bytes;
	
	public var _nativemusic: Dynamic;
	
	public function unload(): Void { }
}
