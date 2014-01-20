package kha;

import haxe.io.Bytes;

class KoreStorageFile extends StorageFile {
	private var name: String;
	
	public function new(name: String) {
		this.name = name;
	}
	
	override public function read(): Blob {
		return null;
	}
	
	override public function write(data: Blob): Void {
		
	}
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		return new KoreStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
