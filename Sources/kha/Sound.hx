package kha;

import haxe.ds.Vector;

/**
 * This represents a Sound file.
 */
class Sound implements Resource {
	/**
	 * The sound data.
	 */
	public var data: Vector<Float>;
	public var compressed: Bool;
	
	public function new() { }

	/**
	 * Unload this sound resource.
	 */
	public function unload() {
		
	}
}
