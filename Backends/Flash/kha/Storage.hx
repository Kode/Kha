package kha;

import flash.net.SharedObject;
import haxe.io.Bytes;

using StringTools;

class FlashStorageFile extends StorageFile {
	private var obj: SharedObject;
	
	public function new(obj: SharedObject) {
		this.obj = obj;
	}
	
	override public function read(): Blob {
		if (obj.data.bytes == null) return null;
		return Blob.fromBytes(Bytes.ofData(obj.data.bytes));
	}
	
	override public function write(data: Blob): Void {
		if (data == null) obj.data.bytes = null;
		else obj.data.bytes = data.bytes;
	}
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		name = name.replace(" ", "_");
		name = name.replace("~", "-");
		name = name.replace("%", "-");
		name = name.replace("&", "-");
		name = name.replace("\\", ".");
		name = name.replace("/", ".");
		name = name.replace(";", ".");
		name = name.replace(":", ".");
		name = name.replace("\"", "*");
		name = name.replace("'", "*");
		name = name.replace(",", ".");
		name = name.replace("<", "-");
		name = name.replace(">", "-");
		name = name.replace("?", "!");
		name = name.replace("#", "-");
		return new FlashStorageFile(SharedObject.getLocal(name));
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
