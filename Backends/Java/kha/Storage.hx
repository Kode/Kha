package kha;

import haxe.io.Bytes;
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import kha.Blob;
import kha.StorageFile;
import sys.io.File;

using StringTools;

class JavaStorageFile extends StorageFile {
	private var file: Path;
	
	public function new(filename: String) {
		this.file = new Path(filename);
		//if (file.dir != null) Directory.CreateDirectory(file.dir);
	}
	
	override public function read(): Blob {
		try {
			if (file == null) return null;
			if (File.getContent(file.toString()) == null) return null;
			return new Blob(File.getBytes(file.toString()));
		}
		catch (e: Dynamic) {
			return null;
		}
	}
	
	override public function write(data: Blob): Void {
		var file = File.write(file.toString(), true);
		file.writeBytes(data.toBytes(), 0, data.toBytes().length);
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
		return new JavaStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
