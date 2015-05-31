package kha.loader;

class Room {
	public var name: String;
	public var assets: Array<Dynamic>;
	public var parent: Room;

	public function new(name: String) {
		this.name = name;
		assets = new Array<Dynamic>();
		parent = null;
	}
}
