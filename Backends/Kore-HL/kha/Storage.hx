package kha;

using StringTools;

class KoreStorageFile extends StorageFile {
	var name: String;

	public function new(name: String) {
		this.name = name;
	}

	override public function read(): Blob {
		var size = 0;
		final bytes = hl_kinc_file_read(StringHelper.convert(name), size);
		if (bytes == null) {
			return null;
		}
		return Blob.fromBytes(@:privateAccess new haxe.io.Bytes(bytes, size));
	}

	override public function write(data: Blob): Void {
		if (data != null) {
			hl_kinc_file_write(StringHelper.convert(name), @:privateAccess data.bytes.b, data.length);
		}
	}

	@:hlNative("std", "kinc_file_read") static function hl_kinc_file_read(name: hl.Bytes, size: hl.Ref<Int>): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_file_write") static function hl_kinc_file_write(name: hl.Bytes, data: Pointer, size: Int): Void {}
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		name = name.replace("\\", ".");
		name = name.replace("/", ".");
		return new KoreStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
