package kha;

import haxe.io.Bytes;

/**
 * This represents a Music file.
 */
class Music implements Resource {
	public function new() { }
	
	/**
	 * The music file in a bytes.
	 */
	public var data: Bytes;
	
	public function unload(): Void { }
}
