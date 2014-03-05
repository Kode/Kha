package kha.loader;

class Room {
	public function new(id: String) {
		this.id = id;
		assets = new Array<Dynamic>();
		parent = null;
	}
	public var id: String;
	public var assets: Array<Dynamic>;
	public var parent: Room;
}