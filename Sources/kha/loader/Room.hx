package kha.loader;

class Room {
	public function new(id: String) {
		this.id = id;
		assets = new Array<Asset>();
		parent = null;
	}
	public var id: String;
	public var assets: Array<Asset>;
	public var parent: Room;
}