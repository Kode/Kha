package kha;

import haxe.io.Bytes;

using StringTools;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/IO/FileReader.h>
#include <Kore/IO/FileWriter.h>
')

class KoreStorageFile extends StorageFile {
	private var name: String;
	
	public function new(name: String) {
		this.name = name;
	}
	
	@:functionCode('
		Kore::FileReader reader;
		if (!reader.open(name, Kore::FileReader::Save)) return null();
		::kha::Blob blob = createBlob(reader.size());
		for (int i = 0; i < reader.size(); ++i) {
			blob->bytes->b->Pointer()[i] = reader.readU8();
		}
		return blob;
	')
	override public function read(): Blob {
		return null;
	}
	
	@:functionCode('
		Kore::FileWriter writer;
		if (!writer.open(name)) return null();
		writer.write(data->bytes->b->Pointer(), data->length());
	')
	override public function write(data: Blob): Void {
		
	}
	
	private static function createBlob(size: Int): Blob {
		return new Blob(Bytes.alloc(size));
	}
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
