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
	
	/**
	 * Instantiate a new sound object.
	 */
	public function new() { }

	/**
	 * Play this sound.
	 *
	 * @return		Return a sound channel.
	 */
	public function play(): SoundChannel {
		return null;
	}

	/**
	 * Unload this sound resource.
	 */
	public function unload() {
		
	}
}
