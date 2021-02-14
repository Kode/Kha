package kha;

/**
 * This represents a Video file.
 */
class Video implements Resource {
	/**
	 * The width of the video file in pixels.
	 */
	public function width(): Int {
		return 100;
	}

	/**
	 * The height of the video file in pixels.
	 */
	public function height(): Int {
		return 100;
	}

	/**
	 * Create a new media object instance.
	 */
	public function new(): Void {}

	/**
	 * Play / resume the media element.
	 * 
	 * @param loop		If playing it looped, default = false.
	 */
	public function play(loop: Bool = false): Void {}

	/**
	 * Pause the media element.
	 */
	public function pause(): Void {}

	/**
	 * Pause the stop element.
	 */
	public function stop(): Void {}

	/**
	 * Return the media length, in milliseconds.
	 */
	public function getLength(): Int { // Milliseconds
		return 0;
	}

	/**
	 * Return the media position, in milliseconds.
	 * Deprecated.
	 */
	public function getCurrentPos(): Int { // Milliseconds
		return 0;
	}

	public var position(get, set): Int;

	function get_position(): Int {
		return 0;
	}

	function set_position(value: Int): Int {
		return 0;
	}

	/**	
	 * Return the media volume, between 0 and 1.
	 */
	public function getVolume(): Float { // [0, 1]
		return 1;
	}

	/**
	 * Set the media volume, between 0 and 1.
	 *
	 * @param volume	The new volume, between 0 and 1.
	 */
	public function setVolume(volume: Float): Void { // [0, 1]
	}

	/**
	 * If the media has finished or not.
	 */
	public function isFinished(): Bool {
		return getCurrentPos() >= getLength();
	}

	/**
	 * Unload the resource from memory.
	 */
	public function unload(): Void {}
}
