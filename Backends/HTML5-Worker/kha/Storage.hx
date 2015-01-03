package kha;

import haxe.io.Bytes;
import haxe.io.BytesData;
import js.html.ArrayBuffer;

class Storage {
	public static function namedFile(name: String): StorageFile {
		return null;
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
