package kha;

import haxe.io.Bytes;
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import kha.Blob;
import kha.StorageFile;
import system.io.Directory;
import system.io.File;

using StringTools;

class WPFStorageFile extends StorageFile {
	private var file: Path;
	
	public function new(filename: String) {
		this.file = new Path(filename);
		if (file.dir != null) Directory.CreateDirectory(file.dir);
	}
	
	override public function read(): Blob {
		if (file == null) return null;
		if (!File.Exists(file.toString())) return null;
		return Blob.fromBytes(Bytes.ofData(File.ReadAllBytes(file.toString())));
	}
	
	override public function write(data: Blob): Void {
		File.WriteAllBytes(file.toString(), data.toBytes().getData());
	}
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		name = name.replace("<", "-(");
		name = name.replace(">", ")-");
		name = name.replace(":", "_");
		name = name.replace("|", ")(");
		name = name.replace("?", "(Q)");
		name = name.replace("*", "(+)");
		name = name.replace("\"", "''");
		return new WPFStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
