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
	
	public function getTextStorage(filename : String) : TextStorage { return null;  }
	public function getKeyValueStorage(path : String) : KeyValueStorage { return null; }
	
	public function makeFilenameString(path : String) : String { return path; }
}

interface KeyValueStorage {
	public function get(key : String) : Dynamic;
	public function set(key : String, value : Dynamic) : Void;
}

interface TextStorage {
	public function save(content : String) : Void;
	public function append(content : String) : Void;
	public function load() : String;
}