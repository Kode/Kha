package kha;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesData;

using StringTools;

class KromStorageFile extends StorageFile {
	var name: String;

	public function new(name: String) {
		this.name = name;
	}

	override public function read(): Blob {
		var data: BytesData = Krom.readStorage(name);
		return data != null ? Blob.fromBytes(Bytes.ofData(data)) : null;
	}

	override public function write(data: Blob): Void {
		if (data != null) {
			Krom.writeStorage(name, data.toBytes().getData());
		}
	}
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		name = name.replace("\\", ".");
		name = name.replace("/", ".");
		return new KromStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
