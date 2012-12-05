package kha.loader;

class Asset {
	public function new(name: String, file: String, type: String) {
		this.name = name;
		this.file = file;
		this.type = type;
	}
	public var name: String;
	public var file: String;
	public var type: String;
}