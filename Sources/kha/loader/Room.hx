package kha.loader;

/**
 * A group of resources that can be loaded.
 */
class Room { // Guess why is this name for ;).
	/**
	 * The name of the group.
	 */
	public var name: String;
	/** 
	 * The group of asset objects.
	 */
	public var assets: Array<Dynamic>;
	/**
	 * The parent group.
	 */
	public var parent: Room;

	/**
	 * Instantiate a new group.
	 *
	 * @param name		The group name.
	 */
	public function new(name: String) {
		this.name = name;
		assets = new Array<Dynamic>();
		parent = null;
	}
}
