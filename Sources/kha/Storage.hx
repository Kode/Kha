package kha;

class Storage {
	static var instance : Storage;
	
	public function new() {
	}
	
	public static function init(storage : Storage) {
		instance = storage;
	}
	
	public static function getInstance() : Storage {
		return instance;
	}
	
	public function saveToFile(filename : String, content : String) { }
	public function appendToFile(filename : String, content : String) { }
	public function loadFromFile(filename : String) : String { return null; }
}